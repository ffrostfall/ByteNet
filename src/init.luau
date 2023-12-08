local RunService = game:GetService("RunService")

local clientPacketIDs = require(script.packets.identifiers.clientPacketIDs)
local serverPacketIDs = require(script.packets.identifiers.serverPacketIDs)
local clientProcess = require(script.process.client.clientProcess)
local serverProcess = require(script.process.server.serverProcess)
local types = require(script.types)

if RunService:IsServer() then
	serverProcess.start()
	serverPacketIDs.start()
else
	clientProcess.start()
	clientPacketIDs.start()
end

return (
	table.freeze({
		createPacket = require(script.packets.packet),

		dataTypes = {
			string = "string",
			uint8 = "uint8",
		},
	}) :: any
) :: types.ByteNet
