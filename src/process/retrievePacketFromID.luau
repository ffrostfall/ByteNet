local RunService = game:GetService("RunService")

local clientPacketIDs = require(script.Parent.Parent.packets.identifiers.clientPacketIDs)
local serverPacketIDs = require(script.Parent.Parent.packets.identifiers.serverPacketIDs)

local isServer = RunService:IsServer()

return function(packetID: number)
	if isServer then
		return serverPacketIDs.getPacketFromID(packetID)
	else
		return clientPacketIDs.getPacketFromID(packetID)
	end
end
