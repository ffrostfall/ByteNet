local bufferWriter = require("../process/bufferWriter")
local types = require("../types")

local writei8 = bufferWriter.writei8

local int8 = {
	write = writei8,

	read = function(b: buffer, cursor: number)
		return buffer.readi8(b, cursor), 1
	end,
}

return function(): types.dataTypeInterface<number>
	return int8
end
