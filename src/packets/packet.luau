--!strict
--!native
--!optimize 2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local client = require(script.Parent.Parent.process.client)
local server = require(script.Parent.Parent.process.server)

local moduleRunContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

return function(props: types.packetProps<types.dataTypeInterface<any>>, id: number)
	-- Basic properties: reliability type, "unique" which is used to get the packet ID, and set up listeners
	local reliabilityType = props.reliabilityType or "reliable"
	local listeners = {}

	local serverSendFunction: (player: Player, id: number, writer: (value: any) -> (), data: any) -> () = if reliabilityType
			== "reliable"
		then server.sendPlayerReliable
		else server.sendPlayerUnreliable

	local serverSendAllFunction: (id: number, writer: (value: any) -> (), data: any) -> () = if reliabilityType
			== "reliable"
		then server.sendAllReliable
		else server.sendAllUnreliable

	local clientSendFunction: (id: number, writer: (value: any) -> (), data: any) -> () = if reliabilityType
			== "reliable"
		then client.sendReliable
		else client.sendUnreliable

	local writer = props.value.write

	local exported = {}
	exported.reader = props.value.read

	function exported.sendTo(data, player: Player)
		assert(moduleRunContext == "server", "The 'sendTo' method can only be called on the server")

		serverSendFunction(player, id, writer, data)
	end

	function exported.sendToAllExcept(data, except: Player)
		assert(moduleRunContext == "server", "The 'sendToAllExcept' method can only be called on the server")

		for _, player: Player in Players:GetPlayers() do
			if player ~= except then
				serverSendFunction(player, id, writer, data)
			end
		end
	end

	function exported.sendToAll(data)
		assert(moduleRunContext == "server", "The 'sendToAll' method can only be called on the server")

		serverSendAllFunction(id, writer, data)
	end

	function exported.send(data)
		assert(moduleRunContext == "client", "The 'send' method can only be called on the client")

		clientSendFunction(id, writer, data)
	end

	function exported.listen(callback)
		table.insert(listeners, callback)
	end

	function exported.getListeners()
		return listeners
	end

	return exported
end
