This folder contains all of the data types contained within ByteNet. They are all imported manually in `src/init.luau`.

Each data type follows the `dataTypeInterface` type. Static types (That don't need any parameters) should generally have the following template:
```lua
local dataTypeName = {
	read = function(b: buffer, cursor: number)
		return value, length
	end,

	write = function(value)
		-- Allocate the data here
		alloc()

		-- write the value here
	end,
}

return function(): dataTypeInterface<type>
	return dataTypeName
end
```

Dynamic data types are a little more performance-costly. They should follow the following format:
```lua
return function(parameter): dataTypeInterface<type>
	return {
		-- Same as static types here
	}
end
```

You will notice that this results in closure duping. This is necessary memory overhead, and while unfortunate, it doesn't actually cost that much. The speed benefits are far greater.

When a data type requires another data type as a parameter, the `read` and `write` functions should be localized like so:
```lua
return function(parameterDataType: dataTypeInterface<any>): dataTypeInterface<type>
	local write = parameterDataType.write
	local read = parameterDataType.read
end
```

While this is a micro optimization, it also helps for readability, so it is generally worth it.