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

-- Externally used for defining packets
export type packetProps<T> = {
	value: T,
	reliabilityType: ("reliable" | "unreliable")?,
	callbackBehavior: {
		spawnThread: boolean,
		allowMultiple: boolean,
	}?,
}

-- Used internally for
export type channelData = {
	cursor: number,
	size: number,
	references: { unknown },
	buff: buffer,
}

-- Used internally for serializing and deserializing all data types
export type dataTypeInterface<T> = {
	write: (value: T) -> (),
	read: (b: buffer, cursor: number) -> (T, number),
	length: number?,
}

-- Somewhat public facing: used as return result in definePacket
type Packet<T> = {
	sendToAll: (data: T) -> (),
	sendTo: (data: T, target: Player) -> (),
	sendToList: (data: T, targets: { Player }) -> (),
	sendToAllExcept: (data: T, exceptions: Player) -> (),

	wait: () -> T,
	send: (data: T, target: Player?) -> (),
	listen: (callback: (data: T, player: Player?) -> ()) -> (),
}

-- Library type
export type ByteNet = {
	definePacket: <T>(props: packetProps<T>) -> Packet<T>,
	defineNamespace: <T>(name: string, namespace: () -> T) -> T,

	struct: <T>(format: T) -> T,
	bool: boolean,
	array: <T>(value: T) -> { [number]: T },
	optional: <T>(value: T) -> T?,
	inst: Instance,
	nothing: nil,
	unknown: unknown,
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
