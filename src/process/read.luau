local RunService = game:GetService("RunService")

local clientPacketIDs = require(script.Parent.Parent.packets.clientPacketIDs)
local serverPacketIDs = require(script.Parent.Parent.packets.serverPacketIDs)
local types = require(script.Parent.Parent.types)

-- Shorthand to avoid having to check if we're on the server or client every time
local retrievePacketFromID = (
	if RunService:IsServer() then serverPacketIDs.getPacketFromID else clientPacketIDs.getPacketFromID
) :: (packetID: number) -> any

return function(incomingBuffer: buffer, player: Player?)
	local length = buffer.len(incomingBuffer)
	local readCursor = 0

	while readCursor < length do
		-- Read packet ID
		local id = buffer.readu8(incomingBuffer, readCursor)
		readCursor += 1

		-- Get packet class, then get packet format
		local packet = retrievePacketFromID(id)
		local format = packet.packetFormat :: types.packetFormat

		local deserialized = {}
		for _, item in format do
			-- item[1] is the reader function for the value type
			-- it'll return the value and the length of the value
			local value, itemLength = ((item[1] :: any) :: (b: buffer, cursor: number) -> (any, number))(
				incomingBuffer,
				readCursor
			)
			readCursor += itemLength

			-- item[3] is the key, so we're converting it into something usable here
			deserialized[item[3]] = value
		end

		for _, listener in packet.listeners do
			task.spawn(listener, deserialized, player)
		end
	end
end
