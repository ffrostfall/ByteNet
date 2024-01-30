local dataTypeList = require(script.Parent.Parent.Parent.storage.dataTypeList)

return function(packetID: number, data: {}, structure: { [number]: { string } })
	local size = 1
	for _, keyDataPair in structure do
		if keyDataPair[2] == "string" then
			local length = string.len(data[keyDataPair[1]])
			size += length + 1
		elseif keyDataPair[2] == "buff" then
			local length = buffer.len(data[keyDataPair[1]])
			size += length + 4
		else
			local dataType = dataTypeList[keyDataPair[2]]

			size += dataType.size or 0
		end
	end

	local packetBuffer = buffer.create(size)
	buffer.writeu8(packetBuffer, 0, packetID)

	local cursor = 1
	for _, keyDataPair in structure do
		local dataType = dataTypeList[keyDataPair[2]]

		cursor += dataType.write(packetBuffer, cursor, data[keyDataPair[1]]) or dataType.size or 0
	end

	return packetBuffer
end
