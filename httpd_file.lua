local Httpd_file = {}
Httpd_file.__index = Httpd_file

function Httpd_file.new()
	local self = setmetatable({}, Httpd_file)
	self.url = "file"
	self.mime = "text/plain"
	self.file = nil
	return self
end

function Httpd_file:http_req_GET(httpd, payload, continue)
	self.file = string.sub(httpd.url, 6)
	return false
end

function Httpd_file:http_res_GET(httpd, continue)
	return httpd:serveFile(self.file, self.mime, nil, continue)
end

function Httpd_file:http_req_POST(httpd, payload, continue)
	local mode
	if (not continue) then
		self.file = string.sub(httpd.url, 6)
		self.count = tonumber(httpd.headers["Content-Length"])
		mode = "w+"
	else
		mode = "a+"
	end
	file.open(self.file, mode)
	file.write(payload)
	file.close()
	self.count = self.count - string.len(payload)
	return self.count > 0
end

function Httpd_file:http_res_POST(httpd, continue)
	return false, httpd:respond200(self.mime, -1, false)
end

return Httpd_file
