local RunService = game:GetService("RunService")

local namespacesDependencies = require(script.Parent.Parent.namespaces.namespacesDependencies)
local values = require(script.Parent.Parent.replicated.values)
local types = require(script.Parent.Parent.types)

local runContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

type structData = {
	[string]: number,
}

return function(input: {
	[string]: types.dataTypeInterface<any>,
}): types.dataTypeInterface<{}>
	-- This is used in the reading/writing parts, and isn't used in the initialization code
	-- It's used to store the index-value pairs and the index-key pairs
	-- Index being the position of the value in the array, and the key being the key in the struct dictionary
	local indexValueTypePairs: {
		[number]: types.dataTypeInterface<any>,
	} = {}
	local indexKeyPairs: { [number]: string } = {}

	--[[
		Array should look like {
			[index (1)] = value
			[index (2)] = value
		}

		Index value type is {
			[index (1)] = int32
		}

		Index key is {
			[index (1)] = "structField"
		}
	]]

	if runContext == "server" then
		local serializedStruct = {}

		-- Convert the struct to an array
		local count = 0
		for key in input do
			count += 1
			serializedStruct[key] = count

			-- Store the index-value pairs and the index-key pairs as a shortcut for serializing n all that
			indexValueTypePairs[count] = input[key]
			indexKeyPairs[count] = key
		end

		-- replicate
		namespacesDependencies.add(serializedStruct)
	elseif runContext == "client" then
		-- There's a layer of complexity added here because we have to access the namespace data
		namespacesDependencies.add(input)

		local name = namespacesDependencies.currentName()

		local namespaceReplicator = values.access(name)
		local namespaceData = namespaceReplicator:read() :: types.namespaceData

		-- struct id is just based on the order of creation in the namespace function
		local structData = namespaceData.structs[namespacesDependencies.currentLength()]

		-- Fetch the data from the server and store it in the index-value pairs and the index-key pairs
		for key, index in structData do
			indexValueTypePairs[index] = input[key]
			indexKeyPairs[index] = key
		end
	end

	return {
		read = function(b, cursor)
			local constructed = table.clone(input)
			local structCursor = cursor

			for index, valueType in indexValueTypePairs do
				local value, length = valueType.read(b, structCursor)

				constructed[indexKeyPairs[index]] = value

				structCursor += length
			end

			return constructed, structCursor - cursor
		end,

		write = function(structValue)
			for index, valueType in indexValueTypePairs do
				valueType.write(structValue[indexKeyPairs[index]])
			end
		end,
	}
end
