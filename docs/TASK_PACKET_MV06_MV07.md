# Task Packet — MV-06 / MV-07

Date: 2026-09-16
Project-wide Canonical: GAME_DEV_MASTER_RULES v1.7
Product Canon: MONSTER VENDING Vertical Slice Final Spec v1.0 + v1.0.1/v1.0.2 balance patches

## Goal
Make the first owned monsters feel like living residents of a Habitat, then instrument and validate the live economy path without changing the locked core loop.

## Non-goals
- No Collection Sheet yet.
- No Machine 02 implementation.
- No battle/breeding/social/backend/IAP/ads.
- No expansion beyond eight species.
- No final art asset production.

## Existing behavior
- VEND -> Machine motion -> Capsule -> Reveal -> Habitat entry exists as code.
- Protected pulls, DNA growth, Machine XP, Reputation and save/load exist as code.
- Runtime verification is blocked until CI/runtime passes.

## Acceptance criteria
### MV-06
- Habitat reads as a living display area rather than an empty inventory grid.
- Capacity 4 and 8 have visibly different layouts.
- Owned monsters have asynchronous ambient life.
- Habitat expansion visibly reacts.
- No per-monster economy calculation is introduced.

### MV-07
- Runtime exposes 60s / 300s / 600s economy checkpoints.
- `coins_blocked_seconds` is measured.
- Offline reward uses 35% income, 8h time cap, and about 3-current-VEND reward cap.
- Save contains a timestamp used for offline reward.
- First VEND and session summary are logged locally with no PII.

## Tests
- `python3 tools/static_validate.py`
- `python3 tools/balance_sanity.py`
- `python3 tools/presentation_static_check.py`
- `python3 tools/economy_static_check.py`

## Visual target
Canonical image: `monster-vending-visual-target-v1.png`.

## Rollback
Revert HabitatDisplay attachment and MV-06/MV-07 script additions; domain save payload remains backward-compatible because `last_save_unix` is optional under schema v2.
