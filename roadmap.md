# Blink — Product Roadmap

> High-level roadmap tracking our journey toward a universal AirDrop alternative.

## Milestones

### M1: The Engine Room 
**Target:** Robust, native cryptography and fast HTTP chunked transfer isolates.
* **Goals:** 
  * End-to-end `libsodium` FFI bindings without throwing exceptions.
  * Successful chunk transfer over HTTP on `localhost` with 100% BLAKE3 verification.
* **Status:** IN PROGRESS

### M2: Offline Handshake 
**Target:** Devices successfully discovering and authenticating with each other fully offline.
* **Goals:** 
  * 100% reliable BLE + mDNS cross-platform discovery.
  * Successful mobile camera QR scan resolving to an identical 256-bit session key on both clients.
* **Status:** PENDING

### M3: The Latest Stitch UI 
**Target:** Visual parity with the "Midnight Obsidian" Figma designs.
* **Goals:** 
  * Smooth 60fps/120fps radar animations.
  * Rebuilt Transfer Cards, Settings, and Onboarding flowing cleanly with `go_router`.
* **Status:** PENDING

### M4: Advanced Sync 
**Target:** Real-time persistence and complex use-cases.
* **Goals:** 
  * Working Live Folders responding instantly to file drops in the OS.
  * Chat module tunneling perfectly over active file pipelines.
  * Classroom Mode testing.
* **Status:** PENDING

### M5: Release Candidate 
**Target:** Hardened launch preparation.
* **Goals:**
  * Clean up previous dead code and stubs.
  * Memory footprint profiling on lengthy multi-GB transfers.
  * Cross-compile and test Linux, Windows, Android natively.
* **Status:** PENDING

---

*Use `implementation_plan.md` for specific granular tasks and daily reviews.*
