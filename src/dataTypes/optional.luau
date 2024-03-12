local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local writebool = bufferWriter.writebool

return function<T>(valueType: types.dataTypeInterface<T>): types.dataTypeInterface<T?>
	local valueRead = valueType.read
	local valueWrite = valueType.write

	return {
		--[[
			first byte is a boolean, if it's true, the next bytes are the value of valueType
			if it's false, its length of 1 cuz only 1 boolean
		]]

		read = function(b: buffer, cursor: number)
			if buffer.readu8(b, cursor) == 0 then
				-- doesn't exist
				return nil, 1
			else
				-- exists, read the value
				local item, length = valueRead(b, cursor + 1)
				return item, length + 1
			end
		end,

		write = function(value: any)
			local exists = value ~= nil

			writebool(exists)

			if exists then
				valueWrite(value)
			end
		end,
	}
end
