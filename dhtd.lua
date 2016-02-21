local Dhtd = {}
Dhtd.__index = Dhtd

function Dhtd.new(p)
	local self = setmetatable({}, Dhtd)
	self.tmr = p
	self.gpio = p
	self.interval = 5000
	self.counter = 0
	self.temperature = 0.0
	self.humidity = 0.0
	
	self.url = "dht"
	
	return self
end

function Dhtd:start()
	tmr.alarm(self.tmr, self.interval, 1, self:getCallback())
end

function Dhtd:getCallback()
	return function()
		_, self.temperature, self.humidity = dht.read(self.gpio)
	end
end

return Dhtd