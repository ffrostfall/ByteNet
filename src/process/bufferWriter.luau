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

local current: types.bufferQueue

local bufferWriter = {}

function bufferWriter.u8(cursor: number, value: number)
	table.insert(current, buffer.writeu8)
	table.insert(current, cursor)
	table.insert(current, value)
	return 1
end

function bufferWriter.i8(cursor: number, value: number)
	table.insert(current, buffer.writei8)
	table.insert(current, cursor)
	table.insert(current, value)
	return 1
end

function bufferWriter.u16(cursor: number, value: number)
	table.insert(current, buffer.writeu16)
	table.insert(current, cursor)
	table.insert(current, value)
	return 2
end

function bufferWriter.i16(cursor: number, value: number)
	table.insert(current, buffer.writei8)
	table.insert(current, cursor)
	table.insert(current, value)
	return 2
end

function bufferWriter.u32(cursor: number, value: number)
	table.insert(current, buffer.writeu32)
	table.insert(current, cursor)
	table.insert(current, value)
	return 4
end

function bufferWriter.writestring(cursor: number, value: string)
	table.insert(current, buffer.writestring)
	table.insert(current, cursor)
	table.insert(current, value)
end

function bufferWriter.i32(cursor: number, value: number)
	table.insert(current, buffer.writei8)
	table.insert(current, cursor)
	table.insert(current, value)
	return 4
end

function bufferWriter.f32(cursor: number, value: number)
	table.insert(current, buffer.writef32)
	table.insert(current, cursor)
	table.insert(current, value)
	return 4
end

function bufferWriter.f64(cursor: number, value: number)
	table.insert(current, buffer.writef64)
	table.insert(current, cursor)
	table.insert(current, value)
	return 8
end

function bufferWriter.copy(targetOffset, source)
	table.insert(current, buffer.copy)
	table.insert(current, targetOffset)
	table.insert(current, source)
end

function bufferWriter.btrue(cursor: number)
	table.insert(current, buffer.writeu8)
	table.insert(current, cursor)
	table.insert(current, 1)
	return 1
end

function bufferWriter.bfalse(cursor: number)
	table.insert(current, buffer.writeu8)
	table.insert(current, cursor)
	table.insert(current, 0)
	return 1
end

function bufferWriter.set(collector)
	current = collector
end

return bufferWriter
