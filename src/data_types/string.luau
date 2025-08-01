local types = require("../types")

local str = {
	-- 2 bytes for the length, then the string

	read = @native function(b: buffer, cursor: number)
		local length = buffer.readu16(b, cursor)

		return buffer.readstring(b, cursor + 2, length), length + 2
	end,
	write = @native function(data: string)
		local length = string.len(data)
		writeu16(length)

		dyn_alloc(length)
		writestring(data)
	end,
}

return @native function(): types.DataType<string>
	return str
end
