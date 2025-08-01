local types = require("../types")

@native
local function optional<T>(value_type: types.DataType<T>): types.DataType<T?>
	local value_read = value_type.read
	local value_write = value_type.write

	return {
		--[[
			first byte is a boolean, if it's true, the next bytes are the value of valueType
			if it's false, its length of 1 cuz only 1 boolean
		]]

		read = @native function(b: buffer, cursor: number)
			if buffer.readu8(b, cursor) == 0 then
				-- doesn't exist
				return nil, 1
			else
				-- exists, read the value
				local item, length = value_read(b, cursor + 1)
				return item, length + 1
			end
		end,

		write = @native function(value: any)
			local exists = value ~= nil

			writebool(exists)

			if exists then
				value_write(value)
			end
		end,
	}
end

return optional
