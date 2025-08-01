local types = require("../types")

local buff = {
	read = @native function(b: buffer, cursor: number)
		local length = buffer.readu16(b, cursor)
		local freshBuffer = buffer.create(length)

		-- copy the data from the main buffer to the new buffer with an offset of 2 because of length
		buffer.copy(freshBuffer, 0, b, cursor + 2, length)

		return freshBuffer, length + 2
	end,
	write = @native function(data: buffer)
		local length = buffer.len(data)
		writeu16(length)

		dyn_alloc(length)

		-- write the length of the buffer, then the buffer itself
		writecopy(data)
	end,
}

return @native function(): types.DataType<buffer>
	return buff
end
