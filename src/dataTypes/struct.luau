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
}): types.dataTypeInterface<any>
	local indexValueTypePairs: {
		[number]: types.dataTypeInterface<any>,
	} = {}
	local indexKeyPairs: { [number]: string } = {}

	if runContext == "server" then
		local serializedStruct = {}

		local count = 0
		for key in input do
			count += 1
			serializedStruct[key] = count

			indexValueTypePairs[count] = input[key]
			indexKeyPairs[count] = key
		end

		namespacesDependencies.add(serializedStruct)
	elseif runContext == "client" then
		-- There's a layer of complexity added here because we have to access the namespace data
		namespacesDependencies.add(input)

		local name = namespacesDependencies.currentName()

		local namespaceReplicator = values.access(name)
		local namespaceData = namespaceReplicator:read() :: types.namespaceData

		local structData = namespaceData.structs[namespacesDependencies.currentLength()]

		for key, index in structData do
			indexValueTypePairs[index] = input[key]
			indexKeyPairs[index] = key
		end
	end

	return {
		read = function(b, cursor)
			local constructed = {}
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
