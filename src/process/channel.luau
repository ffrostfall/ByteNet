local mergeBufferArray = require(script.Parent.mergeBufferArray)

local channelPrototype = {}
local channelMetatable = { __index = channelPrototype }
export type channelType = typeof(setmetatable({} :: {
	_queue: { [number]: buffer },
}, channelMetatable))

function channelPrototype.add(self: channelType, packetBuffer: buffer)
	table.insert(self._queue, packetBuffer)
end

function channelPrototype.flush(self: channelType): buffer?
	if #self._queue == 0 then
		return nil
	end

	local merged = mergeBufferArray(self._queue)
	table.clear(self._queue)

	return merged
end

return function(): channelType
	local self = setmetatable({}, channelMetatable)

	self._queue = {}

	return self
end
