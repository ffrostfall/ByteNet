local types = require("../types")

local vec2 = {
	--[[
		2 float32s, one for X, one for Y
	]]

	read = @native function(b: buffer, cursor: number)
		return Vector2.new(buffer.readf32(b, cursor), buffer.readf32(b, cursor + 4)), 8
	end,

	write = @native function(value: Vector2)
		buffer.writef32(0, 0, value.X)
		buffer.writef32(0, 0, value.Y)
	end,
}

return @native function(): types.DataType<Vector2>
	return vec2
end
