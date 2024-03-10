local bufferWriter = require(script.Parent.Parent.process.bufferWriter)
local types = require(script.Parent.Parent.types)

local u16 = bufferWriter.u16

-- thanks jack :p
return function(
	keyType: types.dataTypeInterface<any>,
	valueType: types.dataTypeInterface<any>
): types.dataTypeInterface<{ [any]: any }>
	-- Cache these functions to avoid the overhead of the index
	local keyWrite = keyType.write
	local valueWrite = valueType.write

	return {
		read = function(b: buffer, cursor: number)
			local map = {}
			local mapCursor = cursor

			-- Read map length
			local mapLength = buffer.readu16(b, mapCursor)
			mapCursor += 2

			for _ = 1, mapLength do
				-- read key/value pairs and add them to the map
				local key, keyLength = keyType.read(b, mapCursor)
				mapCursor += keyLength

				local value, valueLength = valueType.read(b, mapCursor)
				mapCursor += valueLength

				map[key] = value
			end

			-- Return the map, alongside length, because mapCursor - cursor = size
			return map, mapCursor - cursor
		end,
		write = function(map: any)
			local count = 0
			for _ in map do
				count += 1
			end

			-- Write length
			u16(count)

			for k, v in map do
				-- Write key/value pairs
				keyWrite(k)
				valueWrite(v)
			end
		end,
	}
end
