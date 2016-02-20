local Httpd_getFile = {}
Httpd_getFile.__index = Httpd_getFile

function Httpd_getFile.new()
	local self = setmetatable({}, Httpd_getFile)
	self.url = "file"
	self.method = "GET"
	self.mime = "text/plain"
	self.idx = 0
	
	self.file = ""
	self.count = 0
	return self
end

function Httpd_getFile:respond(httpd)
	print("respond")

	self.file = string.sub(httpd.url, 6)
	self.counter = 0
	local buf = httpd:respond200(self.mime, -1, false)
	return true, buf .. "\n"
end

function Httpd_getFile:continue(httpd)
	print("continue", self.count)

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

return Httpd_getFile
