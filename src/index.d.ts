/* eslint-disable @typescript-eslint/no-explicit-any */

declare class packet<T extends ByteNetType<any>> {
  // can't have server and client overloads while keeping dot access to methods because of how typescript works
  listen: (callback: (data: T["value"], player?: Player) => void) => void;
  wait: () => T["value"];

  /** @client */
  send: (data: T["value"]) => void;

  /** @server */
  sendToAll: (data: T["value"]) => void;
  /** @server */
  sendTo: (data: T["value"], player: Player) => void;
  /** @server */
  sendToList: (data: T["value"], players: Player[]) => void;
  /** @server */
  sendToAllExcept: (data: T["value"], exception: Player) => void;
}

type ByteNetType<T> = {
  value: T;
};

declare type array<T extends ByteNetType<any>> = ByteNetType<T["value"][]>;
declare type struct<T extends { [index: string]: ByteNetType<any> }> =
  ByteNetType<{
    [valueName in keyof T]: T[valueName]["value"];
  }>;
declare type optional<T extends ByteNetType<any>> = ByteNetType<
  T["value"] | undefined
>;
declare type map<
  K extends ByteNetType<any>,
  V extends ByteNetType<any>,
> = ByteNetType<Map<K["value"], V["value"]>>;

declare namespace ByteNet {
  export function definePacket<T extends ByteNetType<any>>(packetProps: {
    value: T;
    reliabilityType?: "reliable" | "unreliable";
  }): packet<T>;

  export function defineNamespace<
    T extends {
      [packetName: string]: packet<ByteNetType<any>>;
    },
  >(
    name: string,
    namespaceDefine: () => T,
  ): {
    [packetName in keyof T]: T[packetName];
  };

  // Primitive types
  export const int8: ByteNetType<number>;
  export const int16: ByteNetType<number>;
  export const int32: ByteNetType<number>;
  export const uint8: ByteNetType<number>;
  export const uint16: ByteNetType<number>;
  export const uint32: ByteNetType<number>;
  export const float32: ByteNetType<number>;
  export const float64: ByteNetType<number>;
  export const string: ByteNetType<string>;
  export const bool: ByteNetType<boolean>;
  export const buff: ByteNetType<buffer>;
  export const inst: ByteNetType<Instance>;
  export const cframe: ByteNetType<CFrame>;
  export const vec3: ByteNetType<Vector3>;
  export const vec2: ByteNetType<Vector2>;
  export const nothing: ByteNetType<void>;
  export const unknown: ByteNetType<unknown>;

  // Special types
  export function array<T extends ByteNetType<any>>(type: T): array<T>;
  export function struct<T extends { [index: string]: ByteNetType<any> }>(
    struct: T,
  ): struct<T>;
  export function optional<T extends ByteNetType<any>>(type: T): optional<T>;
  export function map<K extends ByteNetType<any>, V extends ByteNetType<any>>(
    key: K,
    value: V,
  ): map<K, V>;
}

export = ByteNet;
