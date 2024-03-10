local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local u16 = bufferWriter.u16

--[[
	Create a new array with the given dataTypeInterface
]]
return function(valueType: types.dataTypeInterface<any>)
	local valueWrite = valueType.write
	local valueRead = valueType.read

	return {
		read = function(b: buffer, cursor: number)
			local arrayLength = buffer.readu16(b, cursor)
			local arrayCursor = cursor + 2
			local array = {}

			for _ = 1, arrayLength do
				local item, length = valueRead(b, arrayCursor)
				table.insert(array, item)

				arrayCursor += length
			end

			return array, arrayCursor - cursor
		end,
		write = function(value: any)
			local length = #value
			u16(length)

			-- numeric iteration is about 2x faster than generic iteration
			for i = 1, length do
				valueWrite(value[i])
			end
		end,
	}
end
