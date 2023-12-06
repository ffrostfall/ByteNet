local ReplicatedStorage = game:GetService("ReplicatedStorage")

local dataTypeList = require(ReplicatedStorage.Packages.ByteNet.storage.dataTypes.dataTypeList)
local retrievePacketFromID = require(script.Parent.Parent.retrievePacketFromID)

return function(receivedBuffer: buffer)
	local bufferLength = buffer.len(receivedBuffer)

	local cursor = 0
	while cursor <= bufferLength do
		local packetID = buffer.readu8(receivedBuffer, cursor)
		cursor += 1

		local packet = retrievePacketFromID(packetID)
		local packetStructure = {}

		for _, keyDataTypePair in packet._order do
			local key = keyDataTypePair[1]
			local dataType = keyDataTypePair[2]

			local dataTypeInfo = dataTypeList[dataType]
			local size = dataTypeInfo.size

			local length: number?
			packetStructure[key], length = dataTypeInfo.read(receivedBuffer, cursor)

			if length then
				size = length
			end

			cursor += size
		end
	end
end
