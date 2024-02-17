local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local i32 = bufferWriter.i32
local alloc = bufferWriter.alloc

local int32 = {
	write = function(value: number)
		alloc(4)
		i32(value)
	end,

	read = function(b: buffer, cursor: number)
		return buffer.readi32(b, cursor), 4
	end,
}

return function(): types.dataTypeInterface<number>
	return int32
end
