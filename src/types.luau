-- Used internally to define the format of a packet in an efficient way
export type packetFormat = {
	{
		-- read | write | key
		[number]: ((b: buffer, offset: number) -> (any, number)) | ((value: any) -> ()) | string,
	}
}
export type packetFormatElement = ((b: buffer, offset: number) -> (any, number)) | ((value: any) -> ()) | string

export type namespaceData = {
	packets: {
		[string]: any,
	},
	structs: {
		[number]: {
			[string]: any,
		},
	},
}

export type packetProps<T> = {
	value: T,
	reliabilityType: ("reliable" | "unreliable")?,
	callbackBehavior: {
		spawnThread: boolean,
		allowMultiple: boolean,
	}?,
}

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

-- Somewhat public facing: used as return result in definePacket
type Packet<T> = {
	sendToAll: (data: T) -> (),
	send: (data: T, target: Player?) -> (),
	listen: (callback: (data: T, player: Player?) -> ()) -> (),
}

-- Library type
export type ByteNet = {
	definePacket: <T>(props: packetProps<T>) -> Packet<T>,
	defineNamespace: <T>(name: string, namespace: () -> T) -> T,

	struct: <T>(format: T) -> T,
	bool: boolean,
	array: <T>(value: T) -> { T },
	optional: <T>(value: T) -> T?,
	uint8: number,
	uint16: number,
	uint32: number,
	int8: number,
	int16: number,
	int32: number,
	float32: number,
	float64: number,
	string: string,
	vec3: Vector3,
	vec2: Vector2,
	buff: buffer,
	cframe: CFrame,
	map: <K, V>(key: K, value: V) -> { [K]: V },
}

return nil
