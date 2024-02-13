local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local btrue = bufferWriter.btrue
local bfalse = bufferWriter.bfalse

return function(valueType: types.dataTypeInterface<any>)
	return {
		--[[
			first byte is a boolean, if it's true, the next bytes are the value of valueType
			if it's false, its length of 1 cuz only 1 boolean
		]]

		read = function(b: buffer, cursor: number)
			local exists = buffer.readu8(b, cursor)

			if exists == 0 then
				-- doesn't exist
				return nil, 1
			else
				-- exists, read the value
				local item, length = valueType.read(b, cursor + 1)
				return item, length + 1
			end
		end,
		write = function(cursor: number, value: any)
			if value == nil then
				-- preemptively write false
				bfalse(cursor)
				return 1
			end

			-- write true, then the value
			btrue(cursor)
			return valueType.write(cursor + 1, value) + 1
		end,
	}
end :: <T>(valueType: types.dataTypeInterface<T>) -> types.dataTypeInterface<T?>
