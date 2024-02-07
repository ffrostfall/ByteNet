local writeCursor = 0
local readCursor = 0
local packetBuffer = buffer.create(0)
local writers = {}

local dataTypeWriters = {
	u8 = buffer.writeu8,
}
local dataTypeReaders = {
	u8 = function(b: buffer)
		local value = buffer.readu8(b, readCursor)
		readCursor += 1
		return value
	end,
}
local dataTypeLengths = {
	u8 = function()
		return 1
	end,
}

local dataTypes = {
	u8 = "u8",
	dynString = "dynString",
	dynArray = "dynArray",
}

local function createPacketStructure(structure: { [string]: string })
	local structured = {}
	for key, value in structure do
		local accessIndex = dataTypes[value]
		local reader, writer, length =
			dataTypeReaders[accessIndex], dataTypeWriters[accessIndex], dataTypeLengths[accessIndex]

		table.insert(structured, {
			reader = reader,
			writer = writer,
			length = length,
			key = key,
		})
	end
	return structured
end

local allPackets = {
	[1] = createPacketStructure({
		a = dataTypes.u8,
		b = dataTypes.u8,
	}),
}

local function writePacket(
	id: number,
	structure: {
		{
			writer: (b: buffer, offset: number, value: any) -> (),
			reader: (b: buffer, offset: number) -> (),
			key: string,
			length: () -> number,
		}
	},
	dict: { [string]: number }
)
	local idPosition = writeCursor
	table.insert(writers, function()
		buffer.writeu8(packetBuffer, idPosition, id)
	end)
	writeCursor += 1

	for _, value in structure do
		local currentCursor = writeCursor
		table.insert(writers, function()
			value.writer(packetBuffer, currentCursor, dict[value.key])
		end)
		writeCursor += value.length()
	end
end

-- The user sends data
local start = os.clock()
for _ = 1, 1000 do
	writePacket(1, allPackets[1], {
		a = 1,
		b = 2,
	})
end
print(os.clock() - start)

print(allPackets[1])
-- This would be run every frame
local start2 = os.clock()
packetBuffer = buffer.create(writeCursor)
for _, writer in writers do
	writer()
end
table.clear(writers)
print(os.clock() - start2)

-- Reading

local function read(incomingBuffer: buffer)
	local length = buffer.len(incomingBuffer)

	while readCursor < length do
		local id = buffer.readu8(incomingBuffer, readCursor)
		readCursor += 1

		local structure = allPackets[id]
		local deserialized = {}
		for _, item in structure do
			local value = item.reader(incomingBuffer)

			deserialized[item.key] = value
		end
	end
end

read(packetBuffer)
