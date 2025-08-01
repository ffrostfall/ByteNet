local bufferWriter = require("../process/bufferWriter")
local types = require("../types")

local f32 = bufferWriter.writef32

local float32 = {
	write = f32,

	read = function(b: buffer, cursor: number)
		return buffer.readf32(b, cursor), 4
	end,
}

return function(): types.dataTypeInterface<number>
	return float32
end
