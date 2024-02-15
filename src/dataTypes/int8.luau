local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local i8 = bufferWriter.i8

local int8 = {
	write = i8,

	read = function(b: buffer, cursor: number)
		return buffer.readi8(b, cursor), 1
	end,
}

return function(): types.dataTypeInterface<number>
	return int8
end
