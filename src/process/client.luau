local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local read = require(script.Parent.read)
local bufferWriter = require(script.Parent.bufferWriter)

local function onClientEvent(receivedBuffer)
	read(receivedBuffer)
end

-- Shared with: src/process/server.luau (Infeasible to split this into another file)
local EMPTY: types.channelData = {
	cursor = 0,
	size = 64,
	buff = nil :: any,
}

local function load(freshChannel: types.channelData?)
	if not freshChannel then
		local newChannel = table.clone(EMPTY)
		newChannel.buff = buffer.create(64)
		bufferWriter.load(newChannel)
		return
	end

	bufferWriter.load(freshChannel)
end

local function addPacketToLoadedChannel(format: types.packetFormat, data: { [string]: any })
	for _, value in format do
		-- value[2] is the write function, value[3] is the key
		(value[2] :: (cursor: number, value: any) -> number)(data[value[3] :: string])
	end
end

local function dump(channel: types.channelData): buffer
	local dumpBuffer = buffer.create(channel.cursor)
	buffer.copy(dumpBuffer, 0, channel.buff, 0, channel.cursor)
	return dumpBuffer
end
-- No longer shared

local reliable: types.channelData? = nil
local unreliable: types.channelData? = nil

local clientProcess = {}

function clientProcess.sendReliable(id: number, format: types.packetFormat, data: { [string]: any })
	reliable = load(reliable)

	bufferWriter.u8(id)
	addPacketToLoadedChannel(format, data)

	reliable = bufferWriter.export()
end

function clientProcess.sendUnreliable(id: number, format: types.packetFormat, data: { [string]: any })
	unreliable = load(unreliable)

	bufferWriter.u8(id)
	addPacketToLoadedChannel(format, data)

	unreliable = bufferWriter.export()
end

function clientProcess.start()
	local reliableRemote = ReplicatedStorage:WaitForChild("ByteNetReliable")
	reliableRemote.OnClientEvent:Connect(onClientEvent)

	local unreliableRemote = ReplicatedStorage:WaitForChild("ByteNetUnreliable")
	unreliableRemote.OnClientEvent:Connect(onClientEvent)

	RunService.Heartbeat:Connect(function()
		-- Again, checking if there's anything in the channel before we send it.
		if reliable ~= nil then
			reliableRemote:FireServer(dump(reliable))

			-- effectively clears the channel
			reliable = nil
		end

		if unreliable ~= nil then
			unreliableRemote:FireServer(dump(unreliable))

			unreliable = nil
		end
	end)
end

return clientProcess
