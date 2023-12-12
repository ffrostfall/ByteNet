-- all hail Copilot

return {
	uint8 = {
		size = 1,

		min = 0,
		max = 255,

		typecheck = function(value)
			return typeof(value) == "number"
		end,

		checkBounds = function(value)
			return value >= 0 and value <= 255
		end,

		write = function(targetBuffer, offset, value)
			buffer.writeu8(targetBuffer, offset, value)
			return 1
		end,
		read = function(targetBuffer, offset)
			return buffer.readu8(targetBuffer, offset)
		end,
	},
	int8 = {
		size = 1,

		min = -128,
		max = 127,

		checkBounds = function(value)
			return value >= -128 and value <= 127
		end,

		typecheck = function(value)
			return typeof(value) == "number"
		end,

		write = function(targetBuffer, offset, value)
			buffer.writei8(targetBuffer, offset, value)
			return 1
		end,
		read = function(targetBuffer, offset)
			return buffer.readi8(targetBuffer, offset)
		end,
	},

	uint16 = {
		size = 2,

		min = 0,
		max = 65535,

		checkBounds = function(value)
			return value >= 0 and value <= 65535
		end,

		typecheck = function(value)
			return typeof(value) == "number"
		end,

		write = function(targetBuffer, offset, value)
			buffer.writeu16(targetBuffer, offset, value)
			return 2
		end,
		read = function(targetBuffer, offset)
			return buffer.readu16(targetBuffer, offset)
		end,
	},

	int16 = {
		size = 2,

		min = -32768,
		max = 32767,

		checkBounds = function(value)
			return value >= -32768 and value <= 32767
		end,

		typecheck = function(value)
			return typeof(value) == "number"
		end,

		write = function(targetBuffer, offset, value)
			buffer.writei16(targetBuffer, offset, value)
			return 2
		end,
		read = function(targetBuffer, offset)
			return buffer.readi16(targetBuffer, offset)
		end,
	},

	uint32 = {
		size = 4,

		min = 0,
		max = 4294967295,

		checkBounds = function(value)
			return value >= 0 and value <= 4294967295
		end,

		typecheck = function(value)
			return typeof(value) == "number"
		end,

		write = function(targetBuffer, offset, value)
			buffer.writeu32(targetBuffer, offset, value)
			return 4
		end,
		read = function(targetBuffer, offset)
			return buffer.readu32(targetBuffer, offset)
		end,
	},

	int32 = {
		size = 4,

		min = -2147483648,
		max = 2147483647,

		checkBounds = function(value)
			return value >= -2147483648 and value <= 2147483647
		end,

		typecheck = function(value)
			return typeof(value) == "number"
		end,

		write = function(targetBuffer, offset, value)
			buffer.writei32(targetBuffer, offset, value)
			return 4
		end,
		read = function(targetBuffer, offset)
			return buffer.readi32(targetBuffer, offset)
		end,
	},

	ffloat64 = {
		size = 8,

		min = -1.7976931348623157e+308,
		max = 1.7976931348623157e+308,

		typecheck = function(value)
			return typeof(value) == "number"
		end,

		write = function(targetBuffer, offset, value)
			buffer.writef64(targetBuffer, offset, value)
			return 8
		end,
		read = function(targetBuffer, offset)
			return buffer.readf64(targetBuffer, offset)
		end,
	},

	float32 = {
		size = 4,

		min = -3.4028234663852886e+38,
		max = 3.4028234663852886e+38,

		typecheck = function(value)
			return typeof(value) == "number"
		end,

		write = function(targetBuffer, offset, value)
			buffer.writef32(targetBuffer, offset, value)
			return 4
		end,
		read = function(targetBuffer, offset)
			return buffer.readf32(targetBuffer, offset)
		end,
	},

	vec3 = {
		size = 12,

		typecheck = function(value)
			return typeof(value) == "Vector3"
		end,

		write = function(targetBuffer, offset, value)
			buffer.writef32(targetBuffer, offset, value.X)
			buffer.writef32(targetBuffer, offset + 4, value.Y)
			buffer.writef32(targetBuffer, offset + 8, value.Z)
			return 12
		end,
		read = function(targetBuffer, offset)
			return Vector3.new(
				buffer.readf32(targetBuffer, offset),
				buffer.readf32(targetBuffer, offset + 4),
				buffer.readf32(targetBuffer, offset + 8)
			)
		end,
	},

	bool = {
		size = 1,

		typecheck = function(value)
			return typeof(value) == "boolean"
		end,

		write = function(targetBuffer, offset, value)
			buffer.writeu8(targetBuffer, offset, value and 1 or 0)
			return 1
		end,
		read = function(targetBuffer, offset)
			return buffer.readu8(targetBuffer, offset) == 1
		end,
	},

	string = {
		size = nil, -- indeterminate

		typecheck = function(value)
			return typeof(value) == "string"
		end,

		write = function(targetBuffer, offset, targetString)
			local length = #targetString
			buffer.writeu8(targetBuffer, offset, length)
			buffer.writestring(targetBuffer, offset + 1, targetString)
			return length + 1
		end,
		read = function(targetBuffer: buffer, offset)
			local length = buffer.readu8(targetBuffer, offset)
			return buffer.readstring(targetBuffer, offset + 1, length), length + 1
		end,
	},
} :: {
	[string]: {
		size: number?,

		min: number?,
		max: number?,

		read: (targetBuffer: buffer, offset: number) -> (any, number?),
		write: (targetBuffer: buffer, offset: number, data: any) -> number?,
		typecheck: (value: any) -> boolean,
		checkBounds: ((value: number) -> boolean)?,
	},
}
