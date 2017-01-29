Httpd = {}
Httpd.__index = Httpd
Httpd.STATUS_IDLE = 0
Httpd.STATUS_REQ = 1
Httpd.STATUS_REQCNT = 2
Httpd.STATUS_RES = 3
Httpd.STATUS_RESCNT = 4
Httpd.STATUS_END = 5

function Httpd.new(w)
	local self = setmetatable({}, Httpd)
	self.wifid = w
	self.version = "Server: httpd - nodeMCU on ESP8266\r\n"
	self.srv = nil
	self.handlers = {}
	self.count = 0
	return self
end

function Httpd:open(port)
	self.status = Httpd.STATUS_IDLE
	self.srv = net.createServer(net.TCP)
	self.srv:listen(port,
		function(socket)
			socket:on("receive",
				function(conn, request)
					self:processRequest(conn, request)
				end )
			socket:on("sent",
				function(conn)
					self:processResponse(conn)
				end )
		end )
	print(self.version)
end

function Httpd:addHandler(handler)
	self.handlers[handler.url] = handler
end

function Httpd:getHandler(url)
	local handler = nil
	for k, h in pairs(self.handlers) do
		if (string.sub(url, 1, string.len(k)) == k) then
			handler = h
			break
		end
	end
			
	if (handler == nil) then
		return 404, nil
	elseif (handler["http_res_" .. self.method] == nil) then
		return 405, nil
	else
		return 200, handler
	end
end

function Httpd:isAccepted(mime)
	local a,b = string.match(mime, "(%w+)/(%w+)")
	if (self.headers.Accept == nil) then
		return true
	elseif (string.find(self.headers.Accept, mime) ~= nil) then
		return true
	elseif (string.find(self.headers.Accept, a.."/%*")) then
		return true
	elseif (string.find(self.headers.Accept, "%*/"..b)) then
		return true
	elseif (string.find(self.headers.Accept, "%*/%*")) then
		return true
	else
		return false
	end
end

function Httpd:getAccepted(mimes, files, default)
	for i, v in ipairs(mimes) do
		if self:isAccepted(v) then
			return v, (files[i])
		end
	end
	return (mimes[default]), (files[default])
end

function Httpd:parseRequest(request)
	self.headers = {}
	local i = 0
	for line in string.gmatch(request, "(.-)\n") do
		if (i == 0) then
			self.method, self.url, self.params = Httpd.parseMethod(line)
		elseif (line == "") then
			break
		else
			for k, v in string.gmatch(line, "([^:]+):%s*(.+)") do
				self.headers[k] = v
			end
		end
		i = i + 1
	end
	self.status = Httpd.STATUS_IDLE
end

function Httpd:processRequest(conn, request)	
	wifid:flashLed(gpio.LOW)
	
	local payload

	if (self.status == Httpd.STATUS_IDLE) then
		local res
		self:parseRequest(request)
		res, self.handler = self:getHandler(self.url)
		
		if (self.handler == nil) then
			conn:send(self:respond500("No handler"))
			conn:close()
			return
		end
		
		local i, j = string.find(request, "\r\n\r\n")
		if (i ~= nil and i > 0) then
			payload = string.sub(request, j + 1)
		else
			payload = nil
		end
		
		self.status = Httpd.STATUS_REQ
	else
		payload = request
	end
	
	if (self.status == Httpd.STATUS_REQ or
		self.status == Httpd.STATUS_REQCNT) then
		local method = (self.handler["http_req_" .. self.method])
		local more = method(self.handler, self, payload, self.status == Httpd.STATUS_REQCNT)
		if (more) then
			self.status = Httpd.STATUS_REQCNT
		else
			self.status = Httpd.STATUS_RES
			self:processResponse(conn)
		end
	end
end

function Httpd:processResponse(conn)
	if (self.status == Httpd.STATUS_RES or
		self.status == Httpd.STATUS_RESCNT) then
		local handler = (self.handler["http_res_" .. self.method])
		local more, buf = handler(self.handler, self, self.status == Httpd.STATUS_RESCNT)
		
		if (buf ~= nil) then
			if (more) then
				self.status = Httpd.STATUS_RESCNT
			else
				self.status = Httpd.STATUS_END
			end
			conn:send(buf)
			return
		end
	end
	conn:close()
	self.method = nil
	self.url = nil
	self.params = nil
	self.headers = nil
	self.handler = nil
	self.status = Httpd.STATUS_IDLE
	collectgarbage()
end

function Httpd.parseMethod(line)
	local params = {}
	local _, _, method, url, vars = string.find(line, "^([A-Z]+) /([^?]*)%??(.*) HTTP")
	if (vars ~= nil) then
		for k, v in string.gmatch(vars, "(%w+)=?(%w*)&*") do
			params[k] = v
		end
	end
	return method, url, params
end

function Httpd:respond200(mime, size, more)
	local buf = "HTTP/1.1 200 OK\r\n" .. self.version
	if (mime ~= nil) then
		buf = buf .. "Content-Type: " .. mime .. "\r\n"
	end
	if (size > 0) then
		buf = buf .. "Content-Length: " .. size .. "\r\n"
	end
	if (not more) then
		buf = buf .. "\r\n"
	end
	return buf
end

function Httpd:respond404()
	return "HTTP/1.1 404 Not found\r\n" .. self.version .. "\r\n"
end

function Httpd:respond405()
	return "HTTP/1.1 405 Method not allowed\r\n" .. self.version .. "\r\n"
end

function Httpd:respond406()
	return "HTTP/1.1 406 Not Acceptable\r\n" .. self.version .. "\r\n"
end

function Httpd:respond500(err)
	local buf = "HTTP/1.1 500 Error\r\n" .. self.version .. "\r\n"
	buf = buf .. err
	return buf
end

function Httpd:serveFile(fn, mime, replace, continue)
	if (not continue) then
		self.count = 0
		-- test if file exists
		local buf = self:respond200(mime, -1, false)
		return true, buf
	else
		local more, buf
		more, self.count, buf = self:readFile(fn, self.count, 5, replace)
		return more, buf
	end
end

function Httpd:saveFile(fn, payload, continue)
	local mode
	if (not continue) then
		self.count = tonumber(self.headers["Content-Length"])
		mode = "w+"
	else
		mode = "a+"
	end
	file.open(fn, mode)
	file.write(payload)
	file.close()
	self.count = self.count - string.len(payload)
	return self.count > 0
end

function Httpd:readFile(fn, start, lines, replace)
	local buf = ""
	local res = -1
	if file.open(fn, "r") then
		file.seek("set", start)
		while lines > 0 do
			local line = file.readline()
			if (line == nil) then
				break
			else
				if replace ~= nil then
					for k, v in pairs(replace) do
						line = string.gsub(line, "__" .. k .. "__", v)
					end
				end
				buf = buf .. line
			end
			lines = lines - 1
		end
		res = file.seek()
		file.close()
	end
	if buf == "" then
		return false, -1, nil
	else
		return true, res, buf
	end	
end
