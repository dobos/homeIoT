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
	tmr.alarm(self.tmr, self.interval, 1, 
		function(self) 
			_, self.temperature, self.humidity = dht.read(self.gpio)
	
			if (self.dispd ~= nil) then
				self.dispd:setTemperature(self.temperature)
				self.dispd:setHumidity(self.humidity)
			end		
		end)
end

return Dhtd