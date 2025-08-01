local types = require("../types")

local vec3 = {
	__T = ... :: vector,

	read = @native function(b: buffer, cursor: number)
		return vector.create(
			buffer.readf32(b, cursor),
			buffer.readf32(b, cursor + 4),
			buffer.readf32(b, cursor + 8)
		),
			12
	end,

	write = @native function(value: vector)
		buffer.writef32(value.x)
		buffer.writef32(value.y)
		buffer.writef32(value.z)
	end,

	length = 12,
}

return @native function(): types.DataType<vector>
	return vec3
end
