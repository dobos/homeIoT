local Mqttd = {}
Mqttd.__index = Mqttd

function Mqttd.new(server)
	local self = setmetatable({}, Mqttd)
	self.online = false
	self.server = server
	self.tmr = 3
	self.port = 1883
	self.user = "esp"
	self.pass = "esp"
	self.client = nil
	self.handlers = {}
	return self
end

function Mqttd:start()
	self.client = mqtt.Client("esp-" .. node.chipid(), 120, self.user, self.pass)
	
	self.client:on("connect", function()
		print("connected")
		tmr.unregister(self.tmr)
		online = true
	end)
	
	self.client:on("message", function()
		print("message recieved")
	end)
	
	self.client:on("offline", function()
		print("offline, trying to reconnect")
		online = false
		self:connect()
	end)
	
	self:connect()
end

function Mqttd:connect()
	tmr.alarm(self.tmr, 5000, 1, self:getCallback())
end

function Mqttd:getCallback()
	return function()
		print("connecting")
		self.client:connect(self.server, self.port)
	end
end

function Mqttd:publish(topic, payload)
	if online then
		self.client:publish(topic, payload, 0, 0)
	end
end

function Mqttd:subscribe(topic, handler)
	
end

return Mqttd