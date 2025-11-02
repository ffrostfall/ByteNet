--!optimize 2
--!native
local packetIDs = require("../a")
local readRefs = require("./readRefs")

local ref = packetIDs.ref()
local free_thread: thread?

@native
local function function_passer(fn, ...)
	local aquiredThread = free_thread
	free_thread = nil
	fn(...)
	free_thread = aquiredThread
end

@native
local function yielder()
	while true do
		function_passer(coroutine.yield())
	end
end

@native
local function run_listener(fn, ...)
	free_thread = task.spawn(free_thread or task.spawn(coroutine.create(yielder)), fn, ...)
end

@native
local function read(incoming_buff: buffer, references: { [number]: unknown }?, player: Player?)
	local length = buffer.len(incoming_buff)
	local read_cursor = 0

	readRefs.set(references)

	while read_cursor < length do
		local packet = ref[buffer.readu8(incoming_buff, read_cursor)]
		read_cursor += 1

		local value, value_len = packet.reader(incoming_buff, read_cursor)

		read_cursor += value_len

		local listeners = packet.getListeners()
		for i = #listeners, 1, -1 do
			run_listener(listeners[i], value, player)
		end
	end
end

return read
