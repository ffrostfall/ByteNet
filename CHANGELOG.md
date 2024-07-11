# ByteNet Changelog

ByteNet uses [semantic versioning](https://semver.org/spec/v2.0.0.html).

---

## 0.4.6

### Fixes

- Fixed Color3 data type by @buildthomas in [#18](https://github.com/ffrostfall/ByteNet/pull/18)
- Fixed CFrame data type by @HooferDevelops in [16](https://github.com/ffrostfall/ByteNet/pull/16)

### Changes

- Uses a growth factor of 2 over `math.round(1.5)` due to performance

---

## 0.4.4

### Fixes

- Fixed `sendToAllExcept` type

---

## 0.4.3

### Fixes

- Fixed `i16` allocating 8 bytes instead of 2.

### Improvements

- Significant optimization to optional types
- Array serialization is roughly ~2x as efficient
- All data type write functions now directly reference the buffer writer. This means all allocation calls are inlined, and there are roughly ~3x less function calls.

---

## 0.4.2

### Fixes

- Fixed sending unreliable events from client -> server

---

## 0.4.1

### Improvements

- ByteNet now loops through existing players incase the package was initialized late

### Fixes

- Fixed the float64 data type

---

## 0.4.0

### Improvements

- Arrays are now forced to have number indexes

### Fixes

- Added all of the new data types to the ByteNet type.
- Fixed the client not clearing instance references
- Fixed the client sending a buffer every frame
- Fixed instances/unknowns not being sendable in any special type

---

## 0.4.0-rc3

### Added

- Namespaces have been added.
- Structs have been added.
- Three new data types: Instance, unknown, and nothing. The "nothing" type is to allow for packets without any contents.
- Added `:wait()` to packets.

### Improvements

- Packets are now based off closures, instead of metatables. This means you now have to use `.` indexxing instead of `:` to call methods.
- You can now have duplicate packet contents
- Packets now take a single value (Which can be a struct) instead of being "special".
- Significant optimization: Packets are now singular values that can be structs, which reduces complexity, thus increasing performance.

### Fixes

- Added `:sendTo()` to the `Packet` type. This fixes autocomplete.

---

## 0.3.1

### Improvements

- Rewrote serialization to use an allocator w/ resizing instead of using "deferred write" functions. Should be an incredibly large performance boost.

---

## 0.3.0

### Added

- Types: Vector2, CFrame, Array, Optional, Map

### Improvements

- Rewrote client/server processing. Should drastically improve stability and performance.
- Completely re-did how serialization happens to be a lot more stable, and to allow a lot of room for improvement.
- Many type improvements
- Removed only dependency

---

## 0.2.1

### Fixes

- Fixed absolute reference that broke the package. oops.

---

## 0.2.0

### Added

- Added buffer support

### Fixes

- Fixed global queue

### Improvements

- Swapped ordering of packet structure and reliability type
- Reliability type now is an optional argument that defaults to reliable
- Optimization hot path for small amounts of buffers in queue
- Small optimizations

---

## 0.1.3

### Fixes

- Fixed not all data types having types

---

## 0.1.2

### Fixes

- Fixed not all data types being accessible
- Fixed absolute references being used instead of relative references, thanks auto-import..

---

## 0.1.1

### Improvements

- General code improvements/optimizations across the board. Will get more specific as time goes on
- Added roblox-ts support (have not published to npm yet)

### Fixes

- Fixed a basic spamming vulnerability

---

## 0.1.0 (Release)
