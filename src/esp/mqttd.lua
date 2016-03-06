local Mqttd = {}
Mqttd.__index = Mqttd

function Mqttd.new(server, port, user, pass)
	local self = setmetatable({}, Mqttd)
	self.online = false
	self.user = "esp"
	self.pass = nil
	self.client = nil
	self.handlers = {}
	return self
end

function Mqttd:start()
	self.client = mqtt.Client("esp-" .. node.chipid(), 120, self.user, self.pass)
	self.client:on("offline", self:getCallback)
end

function Mqttd:getCallback()
	return function() 
		-- tmr to reconnect
	end
end

function Mqttd:connect()
	self.client:connect(self.server, self.port)
end

function Mqttd:publish(topic, payload)
	self.client:publish(topic, payload, 0, 0)
end

function Mqttd:subscribe(topic, handler)
end

return Mqttd