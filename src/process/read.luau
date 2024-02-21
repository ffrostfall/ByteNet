local packetIDs = require(script.Parent.Parent.namespaces.packetIDs)

local freeThread: thread?

local function functionPasser(fn, ...)
	local aquiredThread = freeThread
	freeThread = nil
	fn(...)
	freeThread = aquiredThread
end

local function yielder()
	while true do
		functionPasser(coroutine.yield())
	end
end

local function runListener(fn, ...)
	if freeThread == nil then
		freeThread = coroutine.create(yielder)
		coroutine.resume(freeThread :: thread)
	end

	task.spawn(freeThread :: thread, fn, ...)
end

local packetIDCache = {}

return function(incomingBuffer: buffer, player: Player?)
	local length = buffer.len(incomingBuffer)
	local readCursor = 0

	while readCursor < length do
		-- Read packet ID
		local id = buffer.readu8(incomingBuffer, readCursor)
		readCursor += 1

		-- Get packet class, then get packet format
		if packetIDCache[id] then
			local value, valueLength = packetIDCache[id].reader(incomingBuffer, readCursor)

			readCursor += valueLength

			for _, listener in packetIDCache[id].getListeners() do
				runListener(listener, value, player)
			end
		else
			local packet = packetIDs.get(id)
			packetIDCache[id] = packet

			local value, valueLength = packet.reader(incomingBuffer, readCursor)

			readCursor += valueLength

			for _, listener in packet.getListeners() do
				runListener(listener, value, player)
			end
		end
	end
end
