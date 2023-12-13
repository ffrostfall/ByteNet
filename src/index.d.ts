declare class Packet<T> {
	/**
	 * @server
	 */
	listen(callback: (data: T, target: Player) => void): void;
	
	/**
	 * @client
	 */
	listen(callback: (data: T) => void): void;
	
	/**
	 * @server
	 */
	sendToAll(data: T): void;
	
	/**
	 * @client
	 */
	send(data: T): void;
	
	/**
	 * @server
	 */
	send(data: T, target: Player): void;
}

interface DataTypes {
	string: string;
	int8: number;
	int16: number;
	int32: number;
	uint8: number;
	uint16: number;
	uint32: number;
	
	float32: number;
	float64: number;
	
	vec3: Vector3;
	
	bool: boolean;
}

interface ByteNet {
	dataTypes: DataTypes,
	
	definePacket: <_, T extends { [index: string]: DataTypes[keyof DataTypes] }>(reliabilityType: "reliable" | "unreliable", structure: T) => Packet<T>;
}