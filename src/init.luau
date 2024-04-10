--!native
--!optimize 2
--!strict

--[[
	I LOVE INLINING I LOVE A MASSIVE 2K LINE FILE I LOVE THE 20 MICROSECOND GAIN I LOVE THE 4% MEMORY REDUCTION
	
	This is a cry for help.
	
	Things I learned working on this codebase:
		- I hate Lua.
		- I love the Luau compiler.
		- All hail WheretIB and Zeuxcg.
		- CPU caching my beloved
		- Hardware is real
]]
local FRESH_CHANNEL_BUFFER_SIZE = 256

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local runContext = if RunService:IsServer() then "server" else "client"

--[[
	Buffer manipulation
	SAFE
]]

type channelData = {
	size: number,
	buff: buffer,
	cursor: number,
}

local template: channelData = {
	size = FRESH_CHANNEL_BUFFER_SIZE,
	buff = nil :: any,
	cursor = 0,
}

local function blankChannel(): channelData
	local freshChannel = table.clone(template)
	freshChannel.buff = buffer.create(FRESH_CHANNEL_BUFFER_SIZE)
	return freshChannel
end

local ref = blankChannel()
local outgoingSize = ref.size
local outgoingBuff = ref.buff
local outgoingCursor = ref.cursor

local function loadChannel(channel: channelData)
	if ref == channel then
		return
	end

	ref = channel
	outgoingSize = channel.size
	outgoingBuff = channel.buff
	outgoingCursor = channel.cursor
end

local function saveChannel()
	ref.cursor = outgoingCursor
	ref.buff = outgoingBuff
	ref.size = outgoingSize
end

local function dumpChannel(channel: channelData): buffer?
	local cursor = channel.cursor
	if cursor == 0 then
		return nil
	end

	local dumpBuffer = buffer.create(cursor)

	buffer.copy(dumpBuffer, 0, channel.buff, 0, cursor)

	-- Reset the cursor to zero to effectively clear it
	channel.cursor = 0

	if channel == ref then
		outgoingCursor = 0
	end

	return dumpBuffer
end

-- FOR SOME DAMN REASON HAVING A GROWTH FACTOR OF MATH.ROUND 1.5 MEANS
-- GET THIS RIGHT
-- IDEK WHY BUT SPECULATIVE EXECUTION MATTERS HERE A LOT
-- I GOT A 50% SPEEDUP BY CHANGING IT TO 2 INSTEAD OF math.round(1.5)
-- I GUESS ITS BECAUSE THE CPU HAS LESS WORK TO DO WHEN IT TRIES TO GUESS IT NEEDS TO RUN THIS FUNCTION.
-- im so DONE OAIJDUISADHASUYD GNSAYTf bdzsyt fdxyugf xdtgyf t
local function alloc(bytes: number)
	if outgoingCursor + bytes < outgoingSize then
		return
	end

	outgoingSize *= 1.5

	local newBuff = buffer.create(outgoingSize)
	buffer.copy(newBuff, 0, outgoingBuff)

	outgoingBuff = newBuff
	return
end

local function dynalloc(bytes: number)
	if outgoingCursor + bytes < outgoingSize then
		return
	end

	-- resize until we can fit the bytes
	while outgoingCursor + bytes > outgoingSize do
		outgoingSize *= 1.5
	end

	local newBuff = buffer.create(outgoingSize)
	buffer.copy(newBuff, 0, outgoingBuff)

	outgoingBuff = newBuff
	return
end

local readFocusBuff: buffer = nil
local readFocusCursor: number = nil
local readFocusPlayer: Player = nil -- server only

--[==[
	primitive writers
]==]
local function writeu8(value: number)
	buffer.writeu8(outgoingBuff, outgoingCursor, value)
	outgoingCursor += 1
end

local function writeu16(value: number)
	buffer.writeu16(outgoingBuff, outgoingCursor, value)
	outgoingCursor += 2
end

local function writebool(value: boolean)
	buffer.writeu8(outgoingBuff, outgoingCursor, if value then 1 else 0)
	outgoingCursor += 1
end

--[==[
	primtive readers
]==]
local function readu8()
	readFocusCursor += 1
	return (buffer.readu8(readFocusBuff, readFocusCursor - 1))
end

local function readu16()
	readFocusCursor += 2
	return (buffer.readu16(readFocusBuff, readFocusCursor - 2))
end

local function readbool()
	readFocusCursor += 1
	return buffer.readu8(readFocusBuff, readFocusCursor - 1) == 1
end
--
--[[
	Incoming
	
	NOT SAFE
]]
type callback = (data: any, player: Player?) -> ()

local packetReaderFunctions = table.create(256, function() end)

local thread: thread? = nil

local function run<T...>(callback: (T...) -> (), ...: T...)
	local threadRef = thread
	thread = nil
	callback(...)
	thread = threadRef
end

local function yielder()
	while true do
		run(coroutine.yield())
	end
end

local function runCallback(callback: (data: any, player: Player?) -> (), data: any, player: Player?)
	if not thread then
		thread = coroutine.create(yielder)
		coroutine.resume(thread :: any)
	end

	task.spawn(callback, data, player)
end

--[[
	Channel declarations
	i hate this codebase SO MUCH PLAESE PLEASEPPLAEPSALDPOSAKf iodaszjgfsreig szrediu gfhbsuy rgdhf
	
	(refactor later.)
]]
local reliableChannel = blankChannel()
local unreliableChannel = blankChannel()

local reliablePlayerChannels: { [Player]: channelData } = {}
local unreliablePlayerChannels: { [Player]: channelData } = {}

--[[
	Initialization
]]
type sharedStruct = {
	[string]: number,
}

local sharedPacketInfo: {
	packets: { [string]: number },
	structs: { [number]: sharedStruct },
} = {
	packets = {},
	structs = {},
}

--[=[
	Data types
]=]
type dataType<T> = {
	write: (value: T) -> (),
	read: () -> T,

	size: number?,
}

-- Primitive data types
local uint8Serdes: dataType<number> = {
	write = writeu8,
	read = readu8,

	size = 1,
}

local boolSerdes = {
	write = writebool,
	read = readbool,

	size = 1,
}

-- Struct data type
local structCount = 0

local function structSerdes(input: { [string]: dataType<any> }): dataType<{ [string]: any }>
	structCount += 1

	local indexKeyPairs = {}
	local indexValuePairs = {}
	local size = 0

	if runContext == "server" then
		local serialized = {}

		local count = 0
		for key in input do
			count += 1

			serialized[key] = count

			indexKeyPairs[count] = key
			indexValuePairs[count] = input[key]

			local element = input[key]
			if element.size ~= nil then
				size += element.size
			end
		end

		sharedPacketInfo.structs[structCount] = serialized
	else
		local replicatedStruct = sharedPacketInfo.structs[structCount]

		local count = 0
		for key in replicatedStruct do
			count += 1

			indexKeyPairs[count] = key
			indexValuePairs[count] = input[key]

			local element = input[key]
			if element.size ~= nil then
				size += element.size
			end
		end
	end

	return {
		read = function()
			local constructed = table.clone(input)

			for index, valueType in indexValuePairs do
				constructed[indexKeyPairs[index]] = valueType.read()
			end

			return constructed
		end,
		write = function(data: any)
			for index, valueType in indexValuePairs do
				valueType.write(data[indexKeyPairs[index]])
			end
		end,

		size = size,
	}
end

-- Complex data types
local function arraySerdes<T>(valueType: dataType<T>): dataType<{ [number]: T }>
	local read = valueType.read
	local write = valueType.write

	local elementSize = valueType.size or 1

	return {
		write = function(arr: { T })
			local elementCount = #arr
			dynalloc((elementSize * elementCount) + 2)
			writeu16(elementCount)

			for i = 1, elementCount do
				write(arr[i])
			end
		end,

		read = function()
			local elementCount = readu16()
			local arr = table.create(elementCount)

			for i = 1, elementCount do
				arr[i] = read()
			end

			return arr
		end,
	}
end

local function mapSerdes<K, V>(keyType: dataType<K>, valueType: dataType<V>): dataType<{ [K]: V }>
	local keyWrite = keyType.write
	local keyRead = keyType.read
	local valueWrite = valueType.write
	local valueRead = valueType.read

	local keySize = keyType.size or 0
	local valueSize = valueType.size or 0

	return {
		write = function(input: { [K]: V })
			local count = 0
			for _ in input do
				count += 1
			end

			dynalloc((keySize * count) + (valueSize * count) + 1)

			writeu8(count)

			for key, value in input do
				keyWrite(key)
				valueWrite(value)
			end
		end,

		read = function()
			local count = readu8()
			local output = {}

			for _ = 1, count do
				local key = keyRead()
				local value = valueRead()

				output[key] = value
			end

			return output
		end,
	}
end

--[[
	Packets
]]
local function addPacketToChannel<T>(
	channel: channelData,
	size: number,
	id: number,
	write: (data: dataType<T>) -> (),
	data: dataType<T>
)
	loadChannel(channel)
	alloc(size)
	writeu8(id)
	write(data)
	saveChannel()
end

type reliabilityType = "reliable" | "unreliable"
type apiPacketParams = {
	value: dataType<any>,
	reliabilityType: reliabilityType,
}
type apiStreamParams = {
	value: dataType<any>,
}

local function clientPacket(name: string, packetParams: apiPacketParams)
	local exported = {}

	local id = sharedPacketInfo.packets[name]

	local write = packetParams.value.write
	local reliable = packetParams.reliabilityType == "reliable"
	local size = (packetParams.value.size or 0) + 1

	packetReaderFunctions[id] = packetParams.value.read

	function exported.listen(callback: callback)
		setPacketListener(id, callback)
	end

	-- Micro-optimization:
	-- if statements are bad. only do them once
	local channel = if reliable then reliableChannel else unreliableChannel

	function exported.send(data: any)
		addPacketToChannel(channel, size, id, write, data)
	end

	return exported :: any
end

local serverPacketCount = 0
local function serverPacket(name: string, packetParams: apiPacketParams)
	serverPacketCount += 1

	local packetID = serverPacketCount
	sharedPacketInfo.packets[name] = packetID
	packetReaderFunctions[packetID] = packetParams.value.read

	local write = packetParams.value.write
	local size = packetParams.value.size or 1

	local exported = {}

	function exported.listen(callback: callback)
		setPacketListener(packetID, callback)
	end

	local globalChannel = if packetParams.reliabilityType == "reliable" then reliableChannel else unreliableChannel
	local playerChannel: { [Player]: channelData } = if packetParams.reliabilityType == "reliable"
		then reliablePlayerChannels
		else unreliablePlayerChannels

	function exported.sendToAll(data: any)
		addPacketToChannel(globalChannel, size, packetID, write, data)
	end

	function exported.sendTo(data: any, player: Player)
		addPacketToChannel(playerChannel[player], size, packetID, write, data)
	end

	return exported :: any
end

--[==[
	Instance setup
]==]
type instances = {
	unreliableRemoteInstance: UnreliableRemoteEvent,
	reliableRemoteInstance: RemoteEvent,
	metaRemoteInstance: RemoteEvent,
	packetInfoInstance: StringValue,
}

local function setupInstances(): instances
	local unreliableRemoteInstance = nil
	local reliableRemoteInstance = nil
	local metaRemoteInstance = nil
	local packetInfoInstance = nil

	if runContext == "server" then
		unreliableRemoteInstance = Instance.new("UnreliableRemoteEvent")
		reliableRemoteInstance = Instance.new("RemoteEvent")
		metaRemoteInstance = Instance.new("RemoteEvent")
		packetInfoInstance = Instance.new("StringValue")

		unreliableRemoteInstance.Name = "BYTENET_UNRELIABLE"
		unreliableRemoteInstance.Parent = ReplicatedStorage

		reliableRemoteInstance.Name = "BYTENET_RELIABLE"
		reliableRemoteInstance.Parent = ReplicatedStorage

		metaRemoteInstance.Name = "BYTENET_META"
		metaRemoteInstance.Parent = ReplicatedStorage

		packetInfoInstance.Name = "BYTENET_PACKETINFO"
		packetInfoInstance.Parent = ReplicatedStorage

		Players.PlayerAdded:Connect(function(player)
			reliablePlayerChannels[player] = blankChannel()
			unreliablePlayerChannels[player] = blankChannel()
		end)
	elseif runContext == "client" then
		unreliableRemoteInstance = ReplicatedStorage:WaitForChild("BYTENET_UNRELIABLE") :: UnreliableRemoteEvent
		reliableRemoteInstance = ReplicatedStorage:WaitForChild("BYTENET_RELIABLE") :: RemoteEvent
		metaRemoteInstance = ReplicatedStorage:WaitForChild("BYTENET_META") :: RemoteEvent
		packetInfoInstance = ReplicatedStorage:WaitForChild("BYTENET_PACKETINFO") :: StringValue
	end

	return {
		unreliableRemoteInstance = unreliableRemoteInstance,
		reliableRemoteInstance = reliableRemoteInstance,
		metaRemoteInstance = metaRemoteInstance,
		packetInfoInstance = packetInfoInstance,
	}
end

local instanceSingleton = nil
local function getInst(): instances
	if not instanceSingleton then
		instanceSingleton = setupInstances()
		return instanceSingleton
	end

	return instanceSingleton
end

--[==[
	Initialization
]==]

--[==[
	Module export
]==]
local function createDefinitions(def: () -> { [any]: any })
	local currentInst = getInst()
	if (currentInst.packetInfoInstance.Value == "") and runContext == "client" then
		while currentInst.packetInfoInstance.Value == "" do
			task.wait()
		end

		sharedPacketInfo = HttpService:JSONDecode(currentInst.packetInfoInstance.Value)
	end

	local definitions = def()

	local tree = {}
	for key, value in definitions do
		if runContext == "server" then
			tree[key] = serverPacket(key, value)
		else
			tree[key] = clientPacket(key, value)
		end
	end

	if runContext == "server" then
		currentInst.packetInfoInstance.Value = HttpService:JSONEncode(sharedPacketInfo)
	end

	return tree
end

local libraryExports = {
	struct = structSerdes,
	array = arraySerdes,
	map = mapSerdes,
	uint8 = uint8Serdes,
	bool = boolSerdes,

	createDefinitions = createDefinitions,

	frame = {
		send = function() end,
		receive = function() end,
	},
}

return table.freeze(libraryExports)
