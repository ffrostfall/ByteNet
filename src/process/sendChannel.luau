local types = require(script.Parent.Parent.types)

local sendChannelPrototype = {}
local sendChannelMetatable = { __index = sendChannelPrototype }
export type sendChannelType = typeof(setmetatable(
	{} :: {
		outgoingBuffer: buffer,
		cursor: number,
		writeJobs: { () -> () },
	},
	sendChannelMetatable
))

function sendChannelPrototype.add(
	self: sendChannelType,
	id: number,
	format: types.packetFormat,
	data: { [string]: any }
)
	local idPosition = self.cursor
	table.insert(self.writeJobs, function()
		buffer.writeu8(self.outgoingBuffer, idPosition, id)
	end)
	self.cursor += 1

	for _, value in format do
		local currentCursor = self.cursor
		table.insert(self.writeJobs, function()
			print(value)
			value.writer(self.outgoingBuffer, currentCursor, data[value.key])
		end)
		self.cursor += value.length()
	end
end

function sendChannelPrototype.empty(self: sendChannelType): buffer?
	if self.cursor == 0 then
		return nil
	end

	self.outgoingBuffer = buffer.create(self.cursor)
	for _, writer in self.writeJobs do
		writer()
	end
	table.clear(self.writeJobs)
	self.cursor = 0

	return self.outgoingBuffer
end

return function(): sendChannelType
	local self = setmetatable({}, sendChannelMetatable)

	self.outgoingBuffer = buffer.create(0)
	self.writeJobs = {}
	self.cursor = 0

	return self
end
