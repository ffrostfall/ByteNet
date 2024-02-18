local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local i8 = bufferWriter.i8
local alloc = bufferWriter.alloc

local int8 = {
	write = function(value: number)
		alloc(1)
		i8(value)
	end,

	read = function(b: buffer, cursor: number)
		return buffer.readi8(b, cursor), 1
	end,
}

return function(): types.dataTypeInterface<number>
	return int8
end
