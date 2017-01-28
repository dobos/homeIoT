Dhtd = {}
Dhtd.__index = Dhtd

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
