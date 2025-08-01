local bufferWriter = require("../process/bufferWriter")
local types = require("../types")

local writef64 = bufferWriter.writef64

local float64 = {
	write = writef64,

	read = function(b: buffer, cursor: number)
		return buffer.readf64(b, cursor), 8
	end,
}

return function(): types.dataTypeInterface<number>
	return float64
end
