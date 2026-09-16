# MONSTER VENDING — Static Checks

Date: 2026-09-16

Automated artifact checks:

- `tools/static_validate.py`
  - 8 canonical species
  - rarity aggregate weights
  - FTUE economy constants
  - Lv2 XP dependency
- `tools/balance_sanity.py`
  - 2000-run 10-minute economy simulation
  - VEND count target
  - unique-species target
  - first Duplicate / Growth timing
  - first Rare timing
  - Habitat-ready timing
- `tools/presentation_static_check.py`
  - active scene nodes
  - Machine / Capsule / Monster / Habitat presentation scripts
  - core sequence references
  - obsolete placeholder UI absence
  - cheap delimiter structural scan
- `tools/economy_static_check.py`
  - offline formula hooks
  - save timestamp hook
  - economy checkpoint instrumentation
  - offline VEND cap sanity

Additional source scan:
- no tab indentation in `.gd` files
- no NUL bytes

## Not verified without Godot runtime
- GDScript parser correctness
- project boot
- actual Tween behavior
- touch input
- Safe Area on real devices
- visual hierarchy on target screens
- FPS / memory / thermals
- real economy checkpoint values
- Android/iOS export
