return function(bufferArray: { [number]: buffer })
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
