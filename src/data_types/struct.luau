local types = require("../types")

type structData = {
	[string]: number,
}

return function<T, V>(input: T & {
	[string]: types.DataType<V>,
}): types.DataType<T>
	local index_value_type_pairs: {
		[number]: types.DataType<any>,
	} = {}
	local index_key_pairs: { [number]: string } = {}

	local count = 0
	for key in input :: any do
		count += 1

		-- Store the index-value pairs and the index-key pairs as a shortcut for serializing n all that
		index_value_type_pairs[count] = input[key]
		index_key_pairs[count] = key
	end

	return {
		__T = nil :: T,

		read = @native function(b, cursor)
			local constructed = table.clone(input)
			local struct_cursor = cursor

			for index, value_type in index_value_type_pairs do
				local value, length = value_type.read(b, struct_cursor)

				constructed[index_key_pairs[index]] = value

				struct_cursor += length
			end

			return constructed, struct_cursor - cursor
		end,

		write = @native function(struct_value)
			for index, value_type in index_value_type_pairs do
				value_type.write(struct_value[index_key_pairs[index]])
			end
		end,
	}
end
