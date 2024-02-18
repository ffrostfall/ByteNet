local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local btrue = bufferWriter.btrue
local bfalse = bufferWriter.bfalse
local alloc = bufferWriter.alloc

return function(valueType: types.dataTypeInterface<
		any
	>)
		local valueWrite = valueType.write

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
			write = function(value: any)
				alloc(1)
				if value == nil then
					-- preemptively write false
					bfalse()
					return
				end

				-- write true, then the value
				btrue()

				-- write the value
				valueWrite(value)
			end,
		}
	end :: <T>(valueType: types.dataTypeInterface<T>) -> types.dataTypeInterface<T?>
