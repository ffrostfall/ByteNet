local RunService = game:GetService("RunService")

local clientPacketIDs = require(script.packets.identifiers.clientPacketIDs)
local serverPacketIDs = require(script.packets.identifiers.serverPacketIDs)
local mergeBufferArray = require(script.process.mergeBufferArray)
local clientProcess = require(script.process.client.clientProcess)
local serverProcess = require(script.process.server.serverProcess)

if RunService:IsServer() then
	serverProcess.start()
	serverPacketIDs.start()
else
	clientProcess.start()
	clientPacketIDs.start()
end

return {
	createPacket = require(script.packets.packet),

	mergeBufferArray = mergeBufferArray,
}
