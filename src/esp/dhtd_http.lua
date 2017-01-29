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