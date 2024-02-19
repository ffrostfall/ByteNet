-- Used internally to define the format of a packet in an efficient way
export type packetFormat = {
	{
		-- read | write | key
		[number]: ((b: buffer, offset: number) -> (any, number)) | ((value: any) -> ()) | string,
	}
}
export type packetFormatElement = ((b: buffer, offset: number) -> (any, number)) | ((value: any) -> ()) | string

-- Used internally to efficiently handle the "deferred write" with buffers
export type bufferQueue = { ((b: buffer, c: number, v: any) -> ()) | number | string | buffer }

export type channelData = {
	cursor: number,
	size: number,
	buff: buffer,
}

-- Used internally for serializing and deserializing all data types
export type dataTypeInterface<T> = {
	write: (value: T) -> (),
	read: (b: buffer, cursor: number) -> (T, number),
}

return nil
