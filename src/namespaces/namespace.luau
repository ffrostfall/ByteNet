local RunService = game:GetService("RunService")

local values = require(script.Parent.Parent.replicated.values)
local types = require(script.Parent.Parent.types)
local namespacesDependencies = require(script.Parent.namespacesDependencies)
local packetIDs = require(script.Parent.packetIDs)

local runContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

local count = 0

return function(
	name: string,
	input: () -> {
		[string]: any,
	}
)
	local namespaceReplicator = values.access(name)

	namespacesDependencies.start(name)
	local packets: {
		[string]: (id: number) -> any,
	} = input()
	local structs = namespacesDependencies.empty()

	local result = {}

	if runContext == "server" then
		local constructedNamespace = {
			structs = {},
			packets = {},
		}

		for key in packets do
			count += 1
			constructedNamespace.packets[key] = count
			result[key] = packets[key](count)

			packetIDs.set(count, result[key])
		end

		for index, value in structs do
			constructedNamespace.structs[index] = value
		end

		namespaceReplicator:write(constructedNamespace)
	elseif runContext == "client" then
		local namespaceData = namespaceReplicator:read() :: types.namespaceData

		for key, packet in packets do
			result[key] = packet(namespaceData.packets[key])

			packetIDs.set(namespaceData.packets[key], result[key])
		end
	end

	return result
end
