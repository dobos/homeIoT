Httpd_file = {}
Httpd_file.__index = Httpd_file

function Httpd_file.new()
	local self = setmetatable({}, Httpd_file)
	self.url = "file"
	self.mime = "text/plain"
	self.file = nil
	return self
end

function Httpd_file:parseUrl(httpd)
	self.file = string.sub(httpd.url, 6)
end

function Httpd_file:http_req_GET(httpd, payload, continue)
	self:parseUrl(httpd)
	return false
end

function Httpd_file:http_res_GET(httpd, continue)
	return httpd:serveFile(self.file, self.mime, nil, continue)
end

function Httpd_file:http_req_POST(httpd, payload, continue)
	self:parseUrl(httpd)
	return httpd:saveFile(self.file, payload, continue)
end

function Httpd_file:http_res_POST(httpd, continue)
	return false, httpd:respond200(self.mime, -1, false)
end
