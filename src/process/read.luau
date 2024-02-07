local types = require(script.Parent.Parent.types)
local retrievePacketFromID = require(script.Parent.Parent.packets.retrievePacketFromID)

return function(incomingBuffer: buffer)
	local length = buffer.len(incomingBuffer)
	local readCursor = 0

	while readCursor < length do
		local id = buffer.readu8(incomingBuffer, readCursor)
		readCursor += 1

		local packet = retrievePacketFromID(id)

		local format = packet.packetFormat :: types.packetFormat

		local deserialized = {}
		for _, item in format do
			local value = item.reader(incomingBuffer, readCursor)
			readCursor += item.length(value)

			deserialized[item.key] = value
		end

		for _, listener in packet.listeners do
			task.spawn(listener, deserialized)
		end
	end
end
