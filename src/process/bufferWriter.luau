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

local size: number
local cursor: number
local buff: buffer
local references: { [number]: unknown }

-- There are not fastcalls for copy and create, so this is slightly faster.
local bufferCopy = buffer.copy
local bufferCreate = buffer.create

local function alloc(bytes: number)
	if not (cursor + bytes >= size) then
		return
	end

	size *= 2

	local newBuffer = bufferCreate(size)
	bufferCopy(newBuffer, 0, buff)

	buff = newBuffer
end

local function dyn_alloc(bytes: number)
	while cursor + bytes >= size do
		size *= 2
	end

	local newBuffer = buffer.create(size)
	buffer.copy(newBuffer, 0, buff)

	buff = newBuffer
end

local bufferWriter = {}

-- this will let alloc and dyn_alloc be inlined for functions in here
bufferWriter.alloc = alloc
bufferWriter.dyn_alloc = dyn_alloc

function bufferWriter.writeu8NoAlloc(value: number)
	buffer.writeu8(buff, cursor, value)
	cursor += 1
end

function bufferWriter.writeu8(value: number)
	alloc(1)
	buffer.writeu8(buff, cursor, value)
	cursor += 1
end

function bufferWriter.writei8(value: number)
	alloc(1)
	buffer.writei8(buff, cursor, value)
	cursor += 1
end

-- this exists solely for the unknown and instance data type. Will likely be obselete soon enough
function bufferWriter.writeReference(value: any)
	table.insert(references, value)
	local index = #references

	buffer.writeu8(buff, cursor, index)
	cursor += 1
end

function bufferWriter.writeu16(value: number)
	alloc(2)
	buffer.writeu16(buff, cursor, value)
	cursor += 2
end

function bufferWriter.writei16(value: number)
	alloc(2)
	buffer.writeu16(buff, cursor, value)
	cursor += 2
end

function bufferWriter.writeu32(value: number)
	alloc(4)
	buffer.writeu32(buff, cursor, value)
	cursor += 4
end

function bufferWriter.writestring(value: string)
	buffer.writestring(buff, cursor, value)
	cursor += string.len(value)
end

function bufferWriter.writei32(value: number)
	alloc(4)
	buffer.writei32(buff, cursor, value)
	cursor += 4
end

function bufferWriter.writef32NoAlloc(value: number)
	buffer.writef32(buff, cursor, value)
	cursor += 4
end

function bufferWriter.writef64NoAlloc(value: number)
	buffer.writef64(buff, cursor, value)
	cursor += 4
end

function bufferWriter.writef32(value: number)
	alloc(4)
	buffer.writef32(buff, cursor, value)
	cursor += 4
end

function bufferWriter.writef64(value: number)
	alloc(8)
	buffer.writef64(buff, cursor, value)
	cursor += 8
end

function bufferWriter.writecopy(value)
	buffer.copy(buff, cursor, value)
	cursor += buffer.len(value)
end

function bufferWriter.writebool(val: boolean)
	alloc(1)
	buffer.writeu8(buff, cursor, if val then 1 else 0)
	cursor += 1
end

function bufferWriter.writePacket(channel: types.channelData, id, writer, data)
	size = channel.size
	cursor = channel.cursor
	references = channel.references
	buff = channel.buff

	alloc(1)
	buffer.writeu8(buff, cursor, id)
	cursor += 1

	writer(data)

	channel.size = size
	channel.cursor = cursor
	channel.references = references
	channel.buff = buff
	return channel
end

return bufferWriter
