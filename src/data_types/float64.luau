local types = require("../types")

local float64: types.DataType<number> = {
	__T = ... :: number,

	write = writef64,

	read = @native function(b: buffer, cursor: number)
		return buffer.readf64(b, cursor), 8
	end,
}

return @native function(): types.DataType<number>
	return float64
end
