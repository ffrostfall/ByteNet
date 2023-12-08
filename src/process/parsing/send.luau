local dataTypeList = require(script.Parent.Parent.Parent.storage.dataTypeList)

return function(packetID: number, data, structure: { [number]: { string } })
	local size = 1
	for _, keyDataPair in structure do
		local dataType = dataTypeList[keyDataPair[2]]

		if keyDataPair[2] == "string" then
			size += 1 + #data[keyDataPair[1]]
		else
			size += dataType.size or 0
		end
	end

	local packetBuffer = buffer.create(size)
	buffer.writeu8(packetBuffer, 0, packetID)

	local cursor = 1
	for _, keyDataPair in structure do
		local dataType = dataTypeList[keyDataPair[2]]

		local length = dataType.write(packetBuffer, cursor, data[keyDataPair[1]])
		cursor += length or dataType.size or 0
	end

	return packetBuffer
end
