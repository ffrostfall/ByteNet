--!native
--!optimize 2

--[[
	Collects all write operations into a queue.
	When the buffer is written, it will be written in the order of the queue.
	
	All operations take in 2 parameters: the cursor and the value.
	Knowing this we can easily attach everything in a nice table, where
	{
		[1] = writer,
		[2] = cursor,
		[3] = value
	}
	
	A lot of these functions just exist as shorthand optimizations.
]]
local types = require(script.Parent.Parent.types)

local current: types.channelData

local size: number
local cursor: number
local buff: buffer

local function alloc(bytes: number)
	if cursor + bytes >= size then
		size = math.floor((size * 1.5))

		local newBuffer = buffer.create(size)
		buffer.copy(newBuffer, 0, buff)

		buff = newBuffer
	end
end

local function dyn_alloc(bytes: number)
	if cursor + bytes >= size then
		while cursor + bytes >= size do
			size = math.floor((size * 1.5))
		end

		local newBuffer = buffer.create(size)
		buffer.copy(newBuffer, 0, buff)

		buff = newBuffer
	end
end

local bufferWriter = {}

bufferWriter.alloc = alloc
bufferWriter.dyn_alloc = dyn_alloc

function bufferWriter.u8(value: number)
	buffer.writeu8(buff, cursor, value)
	cursor += 1
end

function bufferWriter.i8(value: number)
	buffer.writei8(buff, cursor, value)
	cursor += 1
end

function bufferWriter.u16(value: number)
	buffer.writeu16(buff, cursor, value)
	cursor += 2
end

function bufferWriter.i16(value: number)
	buffer.writeu16(buff, cursor, value)
	cursor += 2
end

function bufferWriter.u32(value: number)
	buffer.writeu32(buff, cursor, value)
	cursor += 4
end

function bufferWriter.writestring(value: string)
	buffer.writestring(buff, cursor, value)
	cursor += string.len(value)
end

function bufferWriter.i32(value: number)
	buffer.writei32(buff, cursor, value)
	cursor += 4
end

function bufferWriter.f32(value: number)
	buffer.writef32(buff, cursor, value)
	cursor += 4
end

function bufferWriter.f64(value: number)
	buffer.writef64(buff, cursor, value)
	cursor += 8
end

function bufferWriter.copy(value)
	buffer.copy(buff, cursor, value)
	cursor += buffer.len(value)
end

function bufferWriter.btrue()
	buffer.writeu8(buff, cursor, 1)
	cursor += 1
end

function bufferWriter.bfalse()
	buffer.writeu8(buff, cursor, 0)
	cursor += 1
end

function bufferWriter.load(channel: types.channelData)
	current = channel
	size = channel.size
	cursor = channel.cursor
	buff = channel.buff
end

function bufferWriter.export()
	current.size = size
	current.cursor = cursor
	current.buff = buff

	return current
end

return bufferWriter
