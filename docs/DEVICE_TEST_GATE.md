# MONSTER VENDING — Physical Device Test Gate

Date: 2026-09-16
Status: ACTIVE title-specific implementation of the project-wide mobile device rule.

## Purpose
MONSTER VENDING is a smartphone-first iOS/Android game. Headless CI, parser success, and desktop/editor execution are necessary but cannot substitute for physical-device evidence.

## Hard Gate
No new feature batch may advance beyond the next planned implementation milestone while the current player-facing build has not been exercised on a physical smartphone.

For MONSTER VENDING, the current stop point is MV-08. MV-09 and later feature work is BLOCKED until the Physical Device Gate is passed.

## Gate A — Physical Smartphone Web Build
Purpose: fastest real-device verification of portrait layout, touch input, animation timing, readability, and basic performance.

Required evidence on an actual smartphone:
- build commit SHA
- device model and OS version
- browser used
- launch succeeds
- portrait 720x1280 composition fits without clipped critical controls
- first VEND can be triggered by touch
- Machine -> Capsule -> Reveal -> Habitat sequence completes
- Collection Sheet opens, scrolls if needed, and closes by touch
- no progression blocker through the tested path
- no severe frame pacing, overheating, or input latency issue during the test session
- screenshot or screen recording of at least HOME and one Reveal/Collection state

Web-device PASS is an intermediate gate only. It does not validate native haptics, native lifecycle behavior, Store packaging, or native performance.

## Gate B — Native iOS/Android Build
Required before Release Candidate and earlier whenever native-only behavior is introduced.

Verify on at least one target physical device per platform being shipped:
- native install/launch
- safe area/notch/home-indicator behavior
- touch and gesture handling
- haptics
- audio interruption/resume
- background/foreground lifecycle
- save/load persistence after termination
- offline/return flow
- sustained performance, memory, heat and battery behavior
- platform-specific permissions/SDK behavior when present

## Re-test Triggers
Re-run the relevant physical-device gate after meaningful changes to:
- touch/input routing
- UI layout, Safe Area, orientation or scaling
- rendering, shaders, particles or large assets
- animation/timing/game feel
- audio/haptics
- save/lifecycle/offline behavior
- platform adapters or native SDKs
- performance-sensitive systems

## Progress State
Development status must track:
- LAST VERIFIED DEVICE BUILD: commit SHA
- DEVICE: model / OS / browser or native build
- EVIDENCE: screenshots/recording and checklist result
- BLOCKED: unresolved device-only defects
- NEXT: next implementation milestone allowed after PASS

## Failure Rule
If the build cannot be installed/opened or critical touch/progression is broken, stop feature development and fix that defect first. Do not classify the feature set as DONE based solely on CI/headless success.
