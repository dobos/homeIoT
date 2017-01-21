local Wifid = {}
Wifid.__index = Wifid

function Wifid.new(msg, ssid, pass)
	local self = setmetatable({}, Wifid)
	self.msg = msg
	self.SSID = ssid
	self.password = pass
	self.apcounter = 0
	self.hostname = "esp-" .. node.chipid()
	self.gpio = 8
	self.tmr = 0
	self.interval = 200
	self.counter = 0
	self.gotip = false
	return self
end

function Wifid:start()
	gpio.mode(self.gpio, gpio.OUTPUT)
	gpio.write(self.gpio, gpio.LOW)
		
	tmr.alarm(self.tmr, self.interval, 1, self:getCallback())
	
	self:connect()
end

function Wifid:getCallback()
	return function() self:event() end
end

function Wifid:connect()
	for i = 0, #self.SSID do
		if pcall(function() self:init() end) then
			wifi.sta.connect()
		else
			self.apcounter = self.apcounter + 1
		end
	end
end

function Wifid:init()
	local i = (self.apcounter % #self.SSID) + 1
	wifi.setmode(wifi.STATION)
	wifi.sta.sethostname(self.hostname)
	wifi.sta.setip(self)
	wifi.sta.config(self.SSID[i], self.password[i], 0)
end

function Wifid:event()
	local i = (self.apcounter % #self.SSID) + 1
	local sta = wifi.sta.status()
	local ssid = (self.SSID[i])
	local ip = ""
	local led = 0
		
	if (sta == wifi.STA_IDLE) then
		-- reconnect
		led = 0
	elseif (sta == wifi.STA_CONNECTING) then
		led = math.floor(self.counter / 3) % 2
		self.gotip = false
		if (self.counter % 5 == 0) then
			self.msg:enqueue("wifi connecting to", 1)
			self.msg:enqueue(ssid, 1)
		end
	elseif (sta == wifi.STA_WRONGPWD or sta == wifi.STA_APNOTFOUND or sta == wifi.STA_FAIL) then
		led = self.counter % 2
		self.gotip = false
		
		if (sta == wifi.STA_WRONGPWD) then
			self.msg:enqueue("wrong wifi password", 1)
		elseif (sta == wifi.STA_APNOTFOUND) then
			self.msg:enqueue("wifi AP not found", 1)
		elseif (sta == wifi.STA_FAIL) then
			self.msg:enqueue("wifi connection failed", 1)
		end
		
		wifi.sta.disconnect()
	elseif (sta == wifi.STA_GOTIP) then
		ip, _, _ = wifi.sta.getip()
		led = 1
		if (self.gotip == false) then
			self.msg:enqueue("wifi connected to", 3)
			self.msg:enqueue(ssid, 3)
			self.gotip = true
		end
	end
	
	self:flashLed(led)
	self.counter = self.counter + 1

	if (sta == wifi.STA_WRONGPWD or sta == wifi.STA_APNOTFOUND or sta == wifi.STA_FAIL) then
		self.apcounter = self.apcounter + 1
		self.connect()
	end
end

function Wifid:flashLed(led)
	gpio.write(self.gpio, led)
end

return Wifid