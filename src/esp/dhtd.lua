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
	"dht.json",
	"dht.txt"
}

function Dhtd.new(p)
	local self = setmetatable({}, Dhtd)
	self.gpio = p
	self.temperature = 0.0
	self.humidity = 0.0
	self.url = "dht"
	return self
end

function Dhtd:start()
	tmr.alarm(self.gpio, 5000, 1, self:getCallback())
end

function Dhtd:getCallback()
	return function()
		_, self.temperature, self.humidity = dht.read(self.gpio)
	end
end

function Dhtd:http_req_GET(httpd, payload, continue)
	self.mime, self.file = httpd:getAccepted(Dhtd.MIMES, Dhtd.FILES, #Dhtd.MIMES)
	return false
end

function Dhtd:http_res_GET(httpd, continue)
	local repl = { 
		__t__ = self.temperature,
		__h__ = self.humidity }
	return httpd:serveFile(self.file, self.mime, repl, continue)
end

return Dhtd