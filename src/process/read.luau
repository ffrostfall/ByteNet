--!optimize 2
--!native
local packetIDs = require(script.Parent.Parent.namespaces.packetIDs)
local readRefs = require(script.Parent.readRefs)

local ref = packetIDs.ref()
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

return function(incomingBuffer: buffer, references: { [number]: unknown }?, player: Player?)
	local length = buffer.len(incomingBuffer)
	local readCursor = 0

	readRefs.set(references)

	while readCursor < length do
		local packet = ref[buffer.readu8(incomingBuffer, readCursor)]
		readCursor += 1

		local value, valueLength = packet.reader(incomingBuffer, readCursor)

		readCursor += valueLength

		for _, listener in packet.getListeners() do
			runListener(listener, value, player)
		end
	end
end
