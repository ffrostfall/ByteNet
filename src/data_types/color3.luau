local types = require("../types")

local color3 = {
	__T = ... :: Color3,

	write = @native function(input: Color3)
		alloc(3)
		uint8NoAlloc(input.R * 255)
		uint8NoAlloc(input.G * 255)
		uint8NoAlloc(input.B * 255)
	end,

	read = @native function(b: buffer, cursor: number)
		return Color3.fromRGB(
			buffer.readu8(b, cursor),
			buffer.readu8(b, cursor + 1),
			buffer.readu8(b, cursor + 2)
		),
			3
	end,

	length = 3,
}

return @native function(): types.DataType<Color3>
	return color3
end
