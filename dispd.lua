local Dispd = {}
Dispd.__index = Dispd

function Dispd.new(scl, sda, dhtd)	
	local self = setmetatable({}, Dispd)
	self.dhtd = dhtd
	self.scl = scl
	self.sda = sda
	self.tmr = 1
	self.interval = 1000
	self.counter = 0

	self.heat = true
	self.cool = false
	self.fan = true
	self.humi = true
	self.messages = { "initializing..." }
	return self
end

function Dispd:start()
	i2c.setup(0, self.scl, self.sda, i2c.SLOW)
	self.disp = u8g.ssd1306_128x64_i2c(0x3c)
	self.disp:begin()
	self:render()
	
	tmr.alarm(self.tmr, self.interval, 1, self:getCallback())
end

function Dispd:getCallback()
	return function()
		self:render()
	end
end

function Dispd:render()
	local big
	
	if (self.dhtd ~= nil) then
		if (math.floor(self.counter / 5) % 2 == 0) then
			big = self.dhtd.temperature
		else
			big = self.dhtd.humidity
		end
	end
	
	local msg = (self.messages[self.counter % #self.messages + 1])

	self.disp:firstPage()
	repeat
		-- temp or humi
		self.disp:setFont(u8g.font_fub30)
		self.disp:drawStr(0, 32, big)
		self.disp:setFont(u8g.font_6x10)
		if (msg ~= nil) then
			self.disp:drawStr(0, 62, msg)
		end
		self.disp:setFont(u8g.font_unifont_78_79)
		if (self.cool) then
			self.disp:drawStr(112, 16, "D")
		end
		if (self.heat) then
			self.disp:drawStr(112, 16, "Á")
		end
		if (self.fan) then
			self.disp:drawStr(112, 38, "C")
		end
		if (self.humi) then
			self.disp:drawStr(112, 60, "(")
		end
	until self.disp:nextPage() == false
	
	self.counter = self.counter + 1
end

return Dispd