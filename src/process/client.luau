local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local types = require(script.Parent.Parent.types)
local read = require(script.Parent.read)
local bufferWriter = require(script.Parent.bufferWriter)

local alloc = bufferWriter.alloc
local u8 = bufferWriter.u8
local load = bufferWriter.load

local function onClientEvent(receivedBuffer)
	read(receivedBuffer)
end

-- Shared with: src/process/server.luau (Infeasible to split this into another file)
local function create()
	return {
		cursor = 0,
		size = 256,
		references = {},
		buff = buffer.create(256),
	}
end

local function dump(channel: types.channelData): buffer
	local cursor = channel.cursor
	local dumpBuffer = buffer.create(cursor)

	buffer.copy(dumpBuffer, 0, channel.buff, 0, cursor)

	return dumpBuffer, channel.references
end
-- No longer shared

local reliable: types.channelData = create()
local unreliable: types.channelData = create()

local clientProcess = {}

function clientProcess.sendReliable(id: number, writer: (value: any) -> (), data: { [string]: any })
	reliable = load(reliable)

	alloc(1)
	u8(id)
	writer(data)

	reliable = bufferWriter.export()
end

function clientProcess.sendUnreliable(id: number, writer: (value: any) -> (), data: { [string]: any })
	unreliable = load(unreliable)

	alloc(1)
	u8(id)
	writer(data)

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
			reliable.cursor = 0
		end

		if unreliable ~= nil then
			unreliableRemote:FireServer(dump(unreliable))

			unreliable.cursor = 0
		end
	end)
end

return clientProcess
