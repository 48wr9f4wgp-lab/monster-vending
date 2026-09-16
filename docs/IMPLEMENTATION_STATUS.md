# MONSTER VENDING — Implementation Status

Date: 2026-09-16
Project-wide Canonical: **GAME_DEV_MASTER_RULES v1.7**

## LAST VERIFIED DONE
- MV-01 Project Foundation: scaffold aligned to Final Spec v1.0.
- MV-02 Data Definitions: 8 canonical species + Machine 01 balance data implemented.
- MV-03 Game State / Save: domain logic and save schema v2 implemented as code.
- MV-04 Vend Core Presentation: HOME hierarchy + VEND feedback path implemented as code.
- MV-05 Capsule / Reveal Presentation: Machine -> Capsule -> Reveal -> Habitat entry implemented as code.
- MV-06 Habitat polish: warm/organic Habitat presentation, 4→8 layout, asynchronous ambient creature motion implemented as code.
- MV-07 Economy instrumentation: offline-income calculation, 60/300/600 sec checkpoints, coins-blocked timing and local analytics hooks implemented as code.

## EVIDENCE
- Static validators included under `tools/`.
- 2000-run balance sanity target: median ~11 VEND / 10 min and ~6 unique species.
- GitHub sync branch: `sync-v0.4`.

## BLOCKED / NOT YET VERIFIED
- Godot parser/runtime success
- Actual tween/input behavior success
- Touch behavior success
- Mobile export success
- Real `coins_blocked_seconds` result
- Actual start-vs-10-minute visual comparison

## NEXT
1. Pull-request CI Runtime Gate.
2. Fix parser/runtime failures if any.
3. After runtime passes: MV-08 Collection Sheet.
4. Then MV-09 Duplicate / DNA presentation verification.
5. Then MV-10 Growth Visual pass.

Do not expand beyond eight species until VEND -> REVEAL -> HABITAT and actual waiting-time feel pass runtime/game-feel verification.
