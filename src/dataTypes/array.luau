local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local u16 = bufferWriter.u16

--[[
	Create a new array with the given dataTypeInterface
]]
return function(valueType: types.dataTypeInterface<any>)
	local valueWrite = valueType.write

	return {
		read = function(b: buffer, cursor: number)
			local arrayLength = buffer.readu16(b, cursor)
			local arrayCursor = cursor + 2
			local array = {}

			for _ = 1, arrayLength do
				local item, length = valueType.read(b, arrayCursor)
				table.insert(array, item)

				arrayCursor += length
			end

			return array, (arrayCursor - cursor)
		end,
		write = function(cursor: number, value: any)
			u16(cursor, #value) -- write length, 2 bytes
			local arrayCursor = cursor + 2

			for _, item in value do
				-- add the length of the item to the cursor
				arrayCursor += valueWrite(arrayCursor, item)
			end

			-- return size of the array: arrayCursor - cursor = size
			return arrayCursor - cursor
		end,
	}
end :: <T>(valueType: types.dataTypeInterface<T>) -> types.dataTypeInterface<{ [number]: T }>
