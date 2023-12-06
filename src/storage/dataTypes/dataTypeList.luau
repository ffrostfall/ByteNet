return {
	uint8 = {
		size = 1,

		write = function() end,
		read = function(targetBuffer, offset)
			return buffer.readu8(targetBuffer, offset)
		end,
	},
	string = {
		size = 0, -- indeterminate

		write = function(targetBuffer, offset, targetString)
			local length = #targetString
			buffer.writeu8(targetBuffer, offset, length)
			buffer.writestring(targetBuffer, offset + 1, targetString)
		end,
		read = function(targetBuffer: buffer, offset)
			local length = buffer.readu8(targetBuffer, offset)
			return buffer.readstring(targetBuffer, offset + 1, length), length
		end,
	},
} :: {
	[string]: {
		size: number,

		read: (targetBuffer: buffer, offset: number) -> (any, number?),
		write: (targetBuffer: buffer, offset: number, data: any) -> (),
	},
}
