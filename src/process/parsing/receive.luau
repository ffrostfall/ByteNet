local dataTypeList = require(script.Parent.Parent.Parent.storage.dataTypeList)
local retrievePacketFromID = require(script.Parent.Parent.retrievePacketFromID)

local freeThread: thread? -- Thread reusage

local function passer(callback, data, player): ()
	local acquiredThread = freeThread
	freeThread = nil
	callback(data, player)
	freeThread = acquiredThread
end

local function yielder(): ()
	while true do
		passer(coroutine.yield())
	end
end

return function(receivedBuffer: buffer, player: Player?)
	local bufferLength = buffer.len(receivedBuffer)

	local cursor = 0
	while cursor < bufferLength do
		local packetID = buffer.readu8(receivedBuffer, cursor)
		cursor += 1

		local packet = retrievePacketFromID(packetID)
		local packetStructure = {}

		for _, keyDataTypePair in packet._order do
			local key = keyDataTypePair[1]
			local dataType = keyDataTypePair[2]

			local dataTypeInfo = dataTypeList[dataType]

			local length: number?
			packetStructure[key], length = dataTypeInfo.read(receivedBuffer, cursor)

			cursor += dataTypeInfo.size or length or 0
		end

		for _, callback in packet._listeners do
			if freeThread == nil then
				freeThread = coroutine.create(yielder)
				task.spawn(freeThread :: thread)
			end

			task.spawn(freeThread :: thread, callback, packetStructure, player)
		end
	end
end
