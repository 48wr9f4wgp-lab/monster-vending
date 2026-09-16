# MONSTER VENDING — Godot Vertical Slice v0.4

Production-oriented mobile Vertical Slice scaffold aligned to **Vertical Slice Final Spec v1.0 + canonical patches**, under **GAME_DEV_MASTER_RULES v1.7**.

## Target
- iOS / Android
- Portrait 720×1280 logical viewport
- Touch-first
- Godot 4.7.2 stable target
- GDScript
- Offline single-player

## Implemented as code
### Domain / State
- 8 canonical species
- Protected FTUE Pulls 1–6
- New vs duplicate
- Per-species DNA and ★ growth
- Passive income
- Machine XP / explicit upgrade
- Lv2 Vending Dial
- Reputation / Habitat expansion
- Discovery Guarantee
- Save schema v2 with checksum/backup/read-back verification
- Capped offline income with optional save timestamp

### Presentation
- One-screen HOME hierarchy
- Procedural toy-like Vending Machine
- VEND press feedback
- Machine shake / jam / kick motion
- Capsule drop / shake / pop
- NEW / DUPLICATE reveal overlay
- Placeholder silhouettes for all 8 species
- Signature tap reactions
- NEW Monster flight into Habitat
- Duplicate absorption
- Machine Lv2/Lv3 physical changes
- Living Habitat display with 4→8 layout progression
- Ambient asynchronous creature motion
- Discovery Gauge UI
- Mobile haptic hooks

### Runtime instrumentation
- Economy checkpoints at 60 / 300 / 600 sec
- Coins-blocked timing
- First-VEND timing
- Offline-income event
- Session-end summary

## Static verification performed
- `python3 tools/static_validate.py`
- `python3 tools/balance_sanity.py`
- `python3 tools/presentation_static_check.py`
- `python3 tools/economy_static_check.py`

All pass in the artifact environment.

## Important limitation
No Godot executable is installed in the artifact environment. The project is therefore **not claimed to compile, boot, or run yet**. GDScript parser compatibility, tween behavior, touch behavior, layout, actual pacing and mobile performance require runtime verification.

## Runtime gate
1. Open with Godot 4.7.2 stable.
2. Parse project with no script errors.
3. Boot `Main.tscn`.
4. Verify VEND -> Machine -> Capsule -> Reveal -> Habitat.
5. Verify Habitat life and 4→8 expansion.
6. Verify Duplicate -> Growth.
7. Verify Lv2 -> Dial -> Vend 5.
8. Verify Save / Load / offline reward.
9. Run for 10 minutes and inspect economy checkpoint logs.
10. Capture 0-minute and 10-minute screenshots for visual-growth comparison.
