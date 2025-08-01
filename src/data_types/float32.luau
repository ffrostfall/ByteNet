local types = require("../types")

local float32: types.DataType<number> = {
	__T = ... :: number,

	write = f32,

	read = @native function(b: buffer, cursor: number)
		return buffer.readf32(b, cursor), 4
	end,
}

return @native function(): types.DataType<number>
	return float32
end
