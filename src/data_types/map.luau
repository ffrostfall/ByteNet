local types = require("../types")

@native
local function map(
	keyType: types.DataType<any>,
	valueType: types.DataType<any>
): types.DataType<{ [any]: any }>
	-- Cache these functions to avoid the overhead of the index
	local key_write = keyType.write
	local value_write = valueType.write

	return {
		read = @native function(b: buffer, cursor: number)
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
		write = @native function(map: any)
			local count = 0
			for _ in map do
				count += 1
			end

			-- Write length
			writeu16(count)

			for k, v in map do
				-- Write key/value pairs
				key_write(k)
				value_write(v)
			end
		end,
	}
end

return map
