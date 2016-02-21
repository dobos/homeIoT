local Httpd_file = {}
Httpd_file.__index = Httpd_file

function Httpd_file.new()
	local self = setmetatable({}, Httpd_file)
	self.url = "file"
	self.mime = "text/plain"
	self.idx = 0
	self.file = ""
	self.count = 0
	return self
end

function Httpd_file:http_req_GET(httpd, payload, continue)
	return false
end

function Httpd_file:http_res_GET(httpd, continue)
	if (not continue) then
		self.file = string.sub(httpd.url, 6)
		self.count = 0
		local buf = httpd:respond200(self.mime, -1, false)
		return true, buf .. "\n"
	else
		if file.open(self.file, "r") then
			file.seek("set", self.count)
			local line=file.read(512)
			file.close()
			if line then
				self.count = self.count + string.len(line)
				return true, line
			else
				return false, nil
			end
		end
	end
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