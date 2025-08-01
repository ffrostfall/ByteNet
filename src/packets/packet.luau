--!native
--!optimize 2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local types = require("../types")
local client = require("../process/client")
local server = require("../process/server")

local run_context: "server" | "client" = if RunService:IsServer() then "server" else "client"

--[[
	We use closures here instead of metatables for performance
	It's just faster to use closures than metatables
]]
return@native function(props: types.PacketProps<types.DataType<any>>, id: number)
	-- Basic properties: reliability type, "unique" which is used to get the packet ID, and set up listeners
	local reliabilityType = props.reliability or "reliable"
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
		then client.send_reliable
		else client.send_unreliable

	-- shorcut to avoid indexxing
	local writer = props.value.write

	local exported = {}

	-- RunContext error checking that doesn't have performance drawbacks
	setmetatable(exported, {
		__index =@native function(index)
			if
				(index == "sendTo" or index == "sendToAllExcept" or index == "sendToAll")
				and run_context == "client"
			then
				error("You cannot use sendTo, sendToAllExcept, or sendToAll on the client")
			elseif index == "send" and run_context == "server" then
				error("You cannot use send on the server")
			end
		end,
	})

	-- exposed for the reader file
	exported.reader = props.value.read

	if run_context == "server" then
		function exported.sendToList(data, players: { Player })
			for _, player in players do
				serverSendFunction(player, id, writer, data)
			end
		end

		function exported.sendTo(data, player: Player)
			serverSendFunction(player, id, writer, data)
		end

		function exported.sendToAllExcept(data, except: Player)
			for _, player: Player in Players:GetPlayers() do
				if player ~= except then
					serverSendFunction(player, id, writer, data)
				end
			end
		end

		function exported.sendToAll(data)
			serverSendAllFunction(id, writer, data)
		end
	elseif run_context == "client" then
		function exported.send(data)
			clientSendFunction(id, writer, data)
		end
	end

	function exported.wait()
		-- define it up here so we can use it to disconnect
		local index: number

		local runningThread = coroutine.running()
		table.insert(listeners,@native function(data, player)
			task.spawn(runningThread, data, player)

			-- Disconnects the listener
			table.remove(listeners, index)
		end)

		-- we connected, time to set the index for when we need to disconnect.
		index = #listeners

		-- the listener will resume the thread
		return coroutine.yield()
	end

	function exported.listen(callback)
		table.insert(listeners, callback)
	end

	function exported.getListeners()
		return listeners
	end

	return exported
end
