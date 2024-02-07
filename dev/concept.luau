local cursor = 0
local packetBuffer = buffer.create(0)
local writers = {}

local function writePacket(dict: { [string]: number })
	for key, value in dict do
		local length = 1

		-- Copy the current position of the cursor
		local position = cursor
		table.insert(writers, function()
			buffer.writeu8(packetBuffer, position, value)
		end)

		cursor += length
	end
end

-- The user sends data
writePacket({
	a = 1,
	b = 2,
})

-- This would be run every frame
packetBuffer = buffer.create(cursor)
for _, writer in writers do
	writer()
end
table.clear(writers)
