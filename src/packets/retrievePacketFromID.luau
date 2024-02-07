local RunService = game:GetService("RunService")

local clientPacketIDs = require(script.Parent.Parent.packets.identifiers.clientPacketIDs)
local serverPacketIDs = require(script.Parent.Parent.packets.identifiers.serverPacketIDs)

local isServer = RunService:IsServer()

if isServer then
	return serverPacketIDs.getPacketFromID
else
	return clientPacketIDs.getPacketFromID
end
