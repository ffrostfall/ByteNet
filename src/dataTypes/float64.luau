local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local f64 = bufferWriter.f64

local float64 = {
	write = f64,

	read = function(b: buffer, cursor: number)
		return buffer.readf64(b, cursor), 8
	end,
}

return function(): types.dataTypeInterface<number>
	return float64
end
