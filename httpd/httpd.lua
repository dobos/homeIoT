httpd = {}
httpd.__index = httpd

function httpd.create()
	local h = {}
	setmetatable(h, httpd)
	
	h.version = "Server: httpd - nodeMCU on ESP8266\n"
	h.handlers = {}
	
	return h
end

function httpd:addhandler(method, path, handler)
	
	if (h.handlers[path] == nil) then
		h.handlers[path] = {}
	end
	
	if (h.handlers[path][method] == nil) then
		h.handlers[path][method] = {}
	end
	
	self.handlers[path][method].handler = handler
end

function httpd:open()
	local srv=net.createServer(net.TCP)
	srv:listen(80, function(conn)
		self:connect(conn)
	end )
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

	print("Parsing request...")
	
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
	
	print("  method: " .. method)
	print("  path: " .. path)

	return method, path, params, headers
end

function httpd.parserequest(line)
	
	local _, _, method, path, vars = string.find(line, "([A-Z]+) (.+)?(.+) HTTP");

	if (method == nil) then
		_, _, method, path = string.find(line, "([A-Z]+) (.+) HTTP");
	end

	local params = {}
	
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
	
	print("Building response...")
	
	local data
	local buf = ""
		
	if (self.handlers[path] == nil) then
		buf = buf .. "HTTP/1.1 404 Not found\n"
		buf = buf .. self.version
		buf = buf .. "\n\n"
	elseif (self.handlers[path][method] == nil) then
		buf = buf .. "HTTP/1.1 405 Method not allowed\n"
		buf = buf .. self.version
		buf = buf .. "\n\n"
	elseif (pcall(function() status, mime, data = self.handlers[path][method].handler(params, headers) end)) then
		buf = buf .. "HTTP/1.1 " .. status .. "\n"
		buf = buf .. self.version
		buf = buf .. "Content-Type: " .. mime .. "\n"
		buf = buf .. "\n"
		buf = buf .. (data)
		buf = buf .. "\n\n"
	else
		buf = buf .. "HTTP/1.1 500 Error\n"
		buf = buf .. self.version
		buf = buf .. "\n"
		buf = buf .. "\n"
	end
	
	return buf
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