# MONSTER VENDING — Architecture v0.3

## Current scope
Vertical Slice Final Spec v1.0 + patch v1.0.1/v1.0.2.

## Data
- `data/monsters.json`: eight canonical species, rarity weights, income, tags, body families and reactions.
- `data/machine_01.json`: vend curve, XP gates, reputation gates, habitat capacity and system constants.

## Domain / State
`GameState` owns Coins, Vend sequence/protected FTUE pulls, Collection, per-species DNA/star growth, passive income, Machine XP/explicit upgrade, Reputation, Habitat capacity, Vending Dial and Discovery Guarantee.

Game logic does not depend on scene visuals.

## Persistence
`SaveService` uses schema v2 envelope with `schema_version`, `created_at`, `updated_at`, `payload`, `checksum`. Before replacement it copies the previous save to a backup file, then performs read-back validation.

## Analytics
`AnalyticsService` remains a local sink with an event dictionary and no PII in the slice.

## Presentation boundary
Presentation calls GameState APIs and remains replaceable by final art without moving economy logic into visual nodes.

Current presentation decomposition:
- `MachineDisplay`
- `CapsuleDisplay`
- `MonsterToken`
- `HabitatDisplay`
- `Main` sequence controller

Next major presentation unit: `CollectionSheet`.

## Hard boundaries
- No per-monster `_process` economy.
- No UI mutation of state dictionaries.
- No paid random pull code.
- No Machine 02 implementation in the slice.
- No duplicate creature instances for duplicate pulls; duplicates become DNA/growth.
