-- all hail Copilot

return {
	uint8 = {
		size = 1,

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

		write = function(targetBuffer, offset, value)
			buffer.writei32(targetBuffer, offset, value)
			return 4
		end,
		read = function(targetBuffer, offset)
			return buffer.readi32(targetBuffer, offset)
		end,
	},

	f64 = {
		size = 8,

		write = function(targetBuffer, offset, value)
			buffer.writef64(targetBuffer, offset, value)
			return 8
		end,
		read = function(targetBuffer, offset)
			return buffer.readf64(targetBuffer, offset)
		end,
	},

	f32 = {
		size = 4,

		write = function(targetBuffer, offset, value)
			buffer.writef32(targetBuffer, offset, value)
			return 4
		end,
		read = function(targetBuffer, offset)
			return buffer.readf32(targetBuffer, offset)
		end,
	},

	v3 = {
		size = 12,

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

	string = {
		size = nil, -- indeterminate

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

		read: (targetBuffer: buffer, offset: number) -> (any, number?),
		write: (targetBuffer: buffer, offset: number, data: any) -> number?,
	},
}
