local Msgd = {}
Msgd.__index = Msgd

function Msgd.new()
	local self = setmetatable({}, Msgd)
	self.messages = {}
	self.counts = {}
	self.head = 1
	self.tail = 0
	return self
end

function Msgd:start()
end

function Msgd:enqueue(msg, cnt)
	self.tail = self.tail + 1
	self.messages[self.tail] = msg
	self.counts[self.tail] = cnt
end

function Msgd:dequeue()
	if (self.head > self.tail) then
		return nil
	end
	
	local msg = (self.messages[self.head])
	local cnt = (self.counts[self.head]) - 1
	self.messages[self.head] = nil
	self.counts[self.head] = nil
	
	if (cnt > 0) then
		self:enqueue(msg, cnt)
	end
	
	self.head = self.head + 1
	
	return msg
end

return Msgd
