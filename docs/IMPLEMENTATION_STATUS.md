# MONSTER VENDING — Implementation Status

Date: 2026-09-16
Project-wide Canonical: **GAME_DEV_MASTER_RULES v1.7** (physical-device rule pending project-wide promotion)

## LAST VERIFIED DONE
- MV-01 Project Foundation.
- MV-02 Data Definitions: 8 canonical species + Machine 01 balance data.
- MV-03 Game State / Save: domain logic and save schema v2.
- MV-04 Vend Core Presentation.
- MV-05 Capsule / Reveal Presentation.
- MV-06 Habitat polish: 4→8 layout + ambient creature motion.
- MV-07 Economy instrumentation: offline-income + checkpoints + coins-blocked timing.
- MV-08 Collection Sheet: HOME-preserving bottom sheet, 8 species, discovered/undiscovered states, rarity, ★, DNA and income.
- GitHub Runtime Gate: static validators, Godot 4.7.2 import/parser, and headless runtime smoke all PASS.

## EVIDENCE
- PR #1 synced the v0.4 baseline and passed Godot CI.
- PR #2 implemented MV-08 and passed all static checks + Godot 4.7.2 parser + headless runtime smoke.
- main after MV-08: `ba168228eaf2d162ff12d489183fcaa2e6c279f5`.
- Web Device Test export pipeline is being established in `device-test-gate`.

## BLOCKED / NOT YET VERIFIED
**Feature development is intentionally BLOCKED at MV-08 until physical-device testing passes.**

Not yet verified on an actual smartphone:
- Web export launch in Safari/Chrome on device
- critical touch targets and gesture behavior
- portrait layout / clipping / readability
- VEND -> Capsule -> Reveal -> Habitat complete path by touch
- Collection open/scroll/close by touch
- physical-device frame pacing / heat / input latency
- native iOS/Android Safe Area, haptics, lifecycle and persistence

## NEXT
1. CI-export a single-thread Godot Web build with export templates.
2. Prepare GitHub Pages deployment configuration but do not publish without explicit approval.
3. Open the published test build on a physical smartphone after approval.
4. Record commit SHA + device/OS + screenshots/recording + checklist result.
5. Fix any launch/input/layout/progression defect before MV-09.
6. After Physical Device Gate PASS: MV-09 Duplicate / DNA presentation.

See `docs/DEVICE_TEST_GATE.md`.
