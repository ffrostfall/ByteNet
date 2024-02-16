# ByteNet

This project uses [semantic versioning](https://semver.org/spec/v2.0.0.html).

---

## version 0.3.0

### Added
- Types: Vector2, CFrame, Array, Optional, Map

### Improvements
- Rewrote client/server processing. Should drastically improve stability and performance.
- Completely re-did how serialization happens to be a lot more stable, and to allow a lot of room for improvement.
- Many type improvements
- Removed only dependency

---

## version 0.2.1

### Fixes

- Fixed absolute reference that broke the package. oops.

---

## version 0.2.0

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

## version 0.1.3

### Fixes

- Fixed not all data types having types

---

## version 0.1.2

### Fixes

- Fixed not all data types being accessible
- Fixed absolute references being used instead of relative references, thanks auto-import..

---

## version 0.1.1

### Improvements

- General code improvements/optimizations across the board. Will get more specific as time goes on
- Added roblox-ts support (have not published to npm yet)

### Fixes

- Fixed a basic spamming vulnerability

---

## version 0.1.0 (Release)
