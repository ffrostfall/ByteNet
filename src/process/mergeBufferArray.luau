return function(bufferArray: { [number]: buffer })
	-- Optimization for when there's only 2 buffers to merge
	if #bufferArray == 2 then
		local buffer1 = bufferArray[1]
		local buffer2 = bufferArray[2]

		local buffer1Length = buffer.len(buffer1)
		local buffer2Length = buffer.len(buffer2)

		local mergedBuffer = buffer.create(buffer1Length + buffer2Length)

		buffer.copy(mergedBuffer, 0, buffer1)
		buffer.copy(mergedBuffer, buffer1Length, buffer2)

		return mergedBuffer
	end

	local totalSize = 0
	for _, targetBuffer in bufferArray do
		totalSize += buffer.len(targetBuffer)
	end

	local mergedBuffer = buffer.create(totalSize)

	local bufferCursor = 0
	for _, targetBuffer in bufferArray do
		buffer.copy(mergedBuffer, bufferCursor, targetBuffer)
		bufferCursor += buffer.len(targetBuffer)
	end

	return mergedBuffer
end
