httpd = {}
httpd.__index = httpd

function httpd.create()
	local h = {}
	setmetatable(h, httpd)
	h.version = "Server: httpd - nodeMCU on ESP8266\n"
	h.handlers = {}
	return h
end

function httpd:addhandler(method, path, idx, mime, handler)
	if (h.handlers[path] == nil) then
		h.handlers[path] = {}
	end
	if (h.handlers[path][method] == nil) then
		h.handlers[path][method] = {}
	end
	if (h.handlers[path][method][idx] == nil) then
		h.handlers[path][method][idx] = {}
	end
	self.handlers[path][method][idx].mime = mime
	self.handlers[path][method][idx].handler = handler
end

function httpd:open()
	local srv=net.createServer(net.TCP)
	srv:listen(80, function(conn)
		self:connect(conn)
	end )
	print(self.version)
end

function httpd:connect(conn)
	conn:on("receive", function(client, request)
		self:receive(client, request)
	end )
end

function httpd:receive(client, request)
	local buf = self:buildresponse(self:parse(request))
	client:send(buf)
	client:close()
	collectgarbage()
end

function httpd:parse(request)	
	local method, path, params
	local headers = {}
	local i = 0
	local inheader = true
	for line in string.gmatch(request, "(.-)\n") do
		if (i == 0) then
			method, path, params = self.parserequest(line)
		elseif (inheader) then
			for k, v in self.parseheader(line) do
				headers[k] = v
			end
		else
			-- process request data
		end
		if (line == "") then
			inheader = false
		end
		i = i + 1
	end
	return method, path, params, headers
end

function httpd.parserequest(line)
	local params = {}
	local _, _, method, path, vars = string.find(line, "([A-Z]+) (.+)?(.+) HTTP")
	if (method == nil) then
		_, _, method, path = string.find(line, "([A-Z]+) (.+) HTTP");
	end
	if (vars ~= nil) then
		for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
			params[k] = v
		end
	end
	return method, path, params
end

function httpd.parseheader(line)
	return string.gmatch(line, "([^:]+):(.+)")
end

function httpd:buildresponse(method, path, params, headers)
	local data
	local buf = ""
	if (self.handlers[path] == nil) then
		return self:respond404()
	elseif (self.handlers[path][method] == nil) then
		return self:respond405()
	else
		for idx, handler in ipairs(self.handlers[path][method]) do
			if (self:isaccepted(headers, handler.mime)) then
				if (pcall(function() data = handler.handler(params, headers) end)) then
					buf = buf .. "HTTP/1.1 200 OK\n"
					buf = buf .. self.version
					buf = buf .. "Content-Type: " .. handler.mime .. "\n"
					buf = buf .. "\n"
					buf = buf .. (data)
					buf = buf .. "\n\n"
					return buf
				else
					return self:respond500()
				end
			end
		end
		return self:respond406()
	end
end

function httpd:respond404()
	return "HTTP/1.1 404 Not found\n" .. self.version .. "\n\n"
end

function httpd:respond405()
	return "HTTP/1.1 405 Method not allowed\n" .. self.version .. "\n\n"
end

function httpd:respond406()
	return "HTTP/1.1 406 Not Acceptable\n" .. self.version .. "\n\n"
end

function httpd:respond500()
	return "HTTP/1.1 500 Error\n" .. self.version .. "\n\n"
end

function httpd:isaccepted(headers, mime)
	local a,b = string.match(mime, "(%w+)/(%w+)")
	if (headers.Accept == nil) then
		return true
	elseif (string.find(headers.Accept, mime) ~= nil) then
		return true
	elseif (string.find(headers.Accept, a.."/%*")) then
		return true
	elseif (string.find(headers.Accept, "%*/"..b)) then
		return true
	elseif (string.find(headers.Accept, "%*/%*")) then
		return true
	else
		return false
	end
end

function httpd:loadfile(filename)
	local buf
	
	if (file.open(filename)) then
		buf = file.read()
		file.close()
	end
	
	return buf
end

return httpd