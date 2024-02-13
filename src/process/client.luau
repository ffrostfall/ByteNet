local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local read = require(script.Parent.read)
local bufferWriter = require(script.Parent.bufferWriter)

local function onClientEvent(receivedBuffer)
	read(receivedBuffer)
end

-- Shared with: src/process/server.luau (Infeasible to split this into another file)
type channelData = {
	cursor: number,
	jobs: types.bufferQueue,
}

local cursor = 0
local jobs = {}

local function load(freshChannel: channelData?)
	if not freshChannel then
		cursor = 0
		jobs = {}
		bufferWriter.set(jobs)
		return
	end

	cursor = freshChannel.cursor
	jobs = freshChannel.jobs
	bufferWriter.set(jobs)
end

local function save(): channelData
	return {
		cursor = cursor,
		jobs = jobs,
	}
end

local function addPacketToLoadedChannel(id: number, format: types.packetFormat, data: { [string]: any })
	bufferWriter.u8(cursor, id)
	cursor += 1

	for _, value in format do
		cursor += (value[2] :: (cursor: number, value: any) -> number)(cursor, data[value[3] :: string])
	end
end

local function dumpLoadedChannel(): buffer
	local dumpBuffer = buffer.create(cursor)

	for index = 1, #jobs, 3 do
		(jobs[index] :: (b: buffer, cursor: number, value: any) -> ())(
			dumpBuffer,
			jobs[index + 1] :: number,
			jobs[index + 2]
		)
	end

	return dumpBuffer
end
-- No longer shared

local reliable: channelData? = nil
local unreliable: channelData? = nil

local clientProcess = {}

function clientProcess.sendReliable(id: number, format: types.packetFormat, data: { [string]: any })
	load(reliable)
	addPacketToLoadedChannel(id, format, data)
	reliable = save()
end

function clientProcess.sendUnreliable(id: number, format: types.packetFormat, data: { [string]: any })
	load(unreliable)
	addPacketToLoadedChannel(id, format, data)
	unreliable = save()
end

function clientProcess.start()
	local reliableRemote = ReplicatedStorage:WaitForChild("ByteNetReliable")
	reliableRemote.OnClientEvent:Connect(onClientEvent)

	local unreliableRemote = ReplicatedStorage:WaitForChild("ByteNetUnreliable")
	unreliableRemote.OnClientEvent:Connect(onClientEvent)

	RunService.Heartbeat:Connect(function()
		-- Again, checking if there's anything in the channel before we send it.
		if reliable ~= nil then
			load(reliable)

			reliableRemote:FireServer(dumpLoadedChannel())

			-- effectively clears the channel
			reliable = nil
		end

		if unreliable ~= nil then
			load(unreliable)

			unreliableRemote:FireServer(dumpLoadedChannel())

			unreliable = nil
		end
	end)
end

return clientProcess
