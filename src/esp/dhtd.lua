local Dhtd = {}
Dhtd.__index = Dhtd
Dhtd.MIMES =
{
	"text/html",
	"text/xml",
	"application/json",
	"text/plain"
}
Dhtd.FILES =
{
	"dht.html",
	"dht.xml",
	nil,
	"dht.txt"
}

function Dhtd.new(port)
	local self = setmetatable({}, Dhtd)
	self.gpio = port
	self.temperature = 0.0
	self.humidity = 0.0
	self.url = "dht"
	return self
end

function Dhtd:start()
end

function Dhtd:update()
	_, self.temperature, self.humidity = dht.read(self.gpio)
end

function Dhtd:getPayload()
	return {
		id = node.chipid(),
		temp = self.temperature,
		humi = self.humidity
	}
end

function Dhtd:getJSON()
	return cjson.encode(self:getPayload())
end

function Dhtd:http_req_GET(httpd, payload, continue)
	self.mime, self.file = httpd:getAccepted(Dhtd.MIMES, Dhtd.FILES, #Dhtd.MIMES)
	return false
end

function Dhtd:http_res_GET(httpd, continue)
	if (self.mime == "application/json") then
		if (continue) then
			return false, self:getJSON()
		else
			return true, httpd:respond200(self.mime, -1, false)
		end
	else
		return httpd:serveFile(self.file, self.mime, self:getPayload(), continue)
	end
end

return Dhtd