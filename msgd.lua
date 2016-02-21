local Msgd = {}
Msgd.__index = Msgd

function Msgd.new()
	local self = setmetatable({}, Msgd)
	self.messages = { "initializing..." }
	return self
end

function Msgd:start()
end

return Msgd
