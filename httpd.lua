local Httpd = {}
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
	self.srv = nil
	self.handlers = {}
	return self
end

function Httpd:open(port)
	self.status = Httpd.STATUS_IDLE
	self.srv = net.createServer(net.TCP)
	self.srv:listen(port,
		function(socket)
			socket:on("receive",
				--wifid.flashLed(0)
				function(conn, request)
					self:processRequest(conn, request)
				end )
			socket:on("sent",
				function(conn)
					self:processResponse(conn)
				end )
		end )
	print(self.version())
end

function Httpd:version()
	return "Server: httpd - nodeMCU on ESP8266\n"
end

function Httpd:addHandler(handler)
	self.handlers[handler.url] = handler
end

function Httpd:getHandler()
	local handler = nil
	for k, h in pairs(self.handlers) do
		if (string.sub(self.url, 1, string.len(k)) == k) then
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

function Httpd:parseRequest(request)
	self.headers = {}
	local i = 0
	for line in string.gmatch(request, "(.-)\n") do
		if (i == 0) then
			self.method, self.url, self.params = Httpd.parseMethod(line)
		elseif (line == "") then
			if (method == "POST" or method == "PUT") then
				self.status = Httpd.STATUS_CONTINUE
			else
				self.status = Httpd.STATUS_IDLE
			end
			break
		else
			for k, v in Httpd.parseHeader(line) do
				self.headers[k] = v
			end
		end
		i = i + 1
	end
	self.status = Httpd.STATUS_IDLE
end

function Httpd:processRequest(conn, request)	
	local payload

	if (self.status == Httpd.STATUS_IDLE) then
		local res
		self:parseRequest(request)
		res, self.handler = self:getHandler()
		-- what if wrong handler
		
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
		local more = self.handler["http_req_" .. self.method](self.handler, self, payload, self.status == Httpd.STATUS_REQCNT)
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
		local more, buf = self.handler["http_res_" .. self.method](self.handler, self, self.status == Httpd.STATUS_RESCNT)
		
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
	self.status = Httpd.STATUS_IDLE
	collectgarbage()
end

function Httpd:createResponse()
	local res
	res, self.handler = self:getHandler()
	if (res == 404) then
		return false, self:respond404()
	elseif (res == 405) then
		return false, self:respond405()
	elseif (res == 406) then
		return false, self:respond406()
	else
		return self.handler["http_res_" .. self.method](self.handler, self, false)
	end
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

function Httpd.parseHeader(line)
	return string.gmatch(line, "([^:]+):%s*(.+)")
end

function Httpd:respond200(mime, size, more)
	local buf = "HTTP/1.1 200 OK\n" .. self.version()
	if (mime ~= nil) then
		buf = buf .. "Content-Type: " .. mime .. "\n"
	end
	if (size > 0) then
		buf = buf .. "Content-Length: " .. size .. "\n"
	end
	if (not more) then
		buf = buf .. "\n"
	end
	return buf
end

function Httpd:respond404()
	return "HTTP/1.1 404 Not found\n" .. self.version() .. "\n"
end

function Httpd:respond405()
	return "HTTP/1.1 405 Method not allowed\n" .. self.version() .. "\n"
end

function Httpd:respond406()
	return "HTTP/1.1 406 Not Acceptable\n" .. self.version() .. "\n"
end

function Httpd:respond500(err)
	local buf = "HTTP/1.1 500 Error\n" .. self.version() .. "\n"
	buf = buf .. err
	return buf
end

function Httpd:serveFile(fn, start, lines, replace)
	local buf = ""
	local res = -1
	if file.open(fn, "r") then
		file.seek("set", start)
		
		while lines > 0 do
			local line = file.readline()
			if (line == nil) then
				break
			else
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

return Httpd