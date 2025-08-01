local bufferWriter = require("../process/bufferWriter")
local types = require("../types")

local writei32 = bufferWriter.writei32

local int32 = {
	write = writei32,

	read = function(b: buffer, cursor: number)
		return buffer.readi32(b, cursor), 4
	end,
}

return function(): types.dataTypeInterface<number>
	return int32
end
