# MONSTER VENDING — Product Canon

Date: 2026-09-16
Status: Vertical Slice implementation canon
Visual Canon: `monster-vending-visual-target-v1.png`
Art Canon: `docs/ART_BIBLE.md`
Project-wide Canon: GAME_DEV_MASTER_RULES v1.7

## Product thesis
A portrait mobile creature-collection game where the player owns the world's weirdest Monster Vending Shop. The short-term reward is pressing a tactile machine and revealing a weird-cute creature; the long-term reward is watching owned creatures live in a growing Habitat while the machine/facility transforms.

## Product identity
**Instant Machine Reveal × Living Creature Display × Visible Growth × Machine Transformation**

This is not a battle RPG, not a paid-gacha-first product, and not a static collection book.

## Target
- iOS / Android
- Portrait / touch-first
- 13+ primary audience
- 1–4 minute common sessions; longer play allowed
- Offline-first single-player for Vertical Slice
- No backend/account/IAP/ads in Vertical Slice

## Core loop
Income → Coins → VEND → Capsule → Reveal → NEW or Duplicate → Habitat/Growth → Machine XP/Reputation → Machine/Habitat progress → next VEND.

## Product pillars
1. PRESS — the machine itself is irresistible to touch.
2. DISCOVER — short anticipation before reveal.
3. LOVE — every creature has a memorable silhouette and signature reaction.
4. GROW — duplicate results visibly grow an owned creature.
5. DISPLAY — collection lives in the Habitat.
6. TRANSFORM — machine and facility visibly change.

## Vertical Slice scope
- Machine 01 only, with Lv1/Lv2/Lv3 visual states
- 8 species
- 1 Habitat, capacity 4 → 8
- 3–5 simple decorations
- 1 variant capability only
- Machine 02 silhouette teaser only
- Save/load, audio/VFX/haptics hooks, local analytics, mobile performance instrumentation

## Initial species
- PUFF — Common — inflates on tap; hero candidate
- BLOOP — Common — squash/recover
- SHROOMY — Common — sudden sleep; plant interaction
- PRICKY — Uncommon — angry/spikes
- PEEKO — Uncommon — eye/finger attention
- GOBBLE — Rare — food obsession
- SPARKY — Epic — electric sneeze
- MIMIC — Legendary — capsule mimic trying to return to the machine; hero candidate

## Protected FTUE pulls
1. PUFF fixed / NEW / FREE
2. NEW guaranteed
3. NEW guaranteed
4. PUFF duplicate → first DNA / ★2
5. Vending Dial + NEW from selected bias
6. Rare guaranteed, GOBBLE candidate
7+. Normal pool + Discovery Guarantee

## Economy canon — Vertical Slice test values
Starting Coins: 10

VEND costs:
`0, 20, 60, 160, 220, 240, 250, 260, 270, 280, 290, 300, 310`, then +10 per VEND.

Base income / sec:
- Common 0.60
- Uncommon 0.75
- Rare 0.95
- Epic 1.20
- Legendary 1.50

Star multipliers: ★1 ×1.0 / ★2 ×1.5 / ★3 ×2.2

DNA:
- ★1→★2: 1 duplicate
- ★2→★3: +3 duplicate DNA
- maxed duplicate: Coins + Machine XP

Machine XP cumulative thresholds: Lv2 7 / Lv3 20 / Lv4 34 / Lv5 52. Machine upgrades cost no Coins.

Reputation unlocks: 30 Decoration / 45 Habitat 4→8 / 75 visual upgrade candidate / 120 future Machine 02 condition candidate.

Offline income: 35% of active rate, max 8h, also capped to about 3 current VENDs.

## Rarity test weights
Common 52% / Uncommon 28% / Rare 13% / Epic 5.5% / Legendary 1.5%.

## UI canon
HOME is the game. Visual hierarchy: Monster/Reveal → Machine → VEND → Habitat → Progress → secondary HUD. VEND stays bottom-center; Reveal is an overlay; navigation stays shallow.

## FTUE targets
First VEND ≤10 sec; visible input response ≤100 ms; Common reveal ~1.8–2.2 sec; first duplicate/growth 2–4 min; first Rare 4–7 min; Habitat expansion 6–10 min; Machine 02 teaser ~10 min; 10-minute VEND count 10–13; unique species ~5–6.

## Critical path
PRESS → MACHINE REACTS → CAPSULE → REVEAL → MONSTER REACTS → HABITAT ENTRY → NEXT VEND.

Do not expand content until this passes runtime/game-feel verification.

## Non-goals
No battle, breeding, PvP, trading, multiplayer, backend, account, IAP, ads, daily login, battle pass, seasonal event, Machine 02 implementation, portal, Giant Monster, heavy story, or complex crafting.

## Ethics
Short-cycle delight comes from anticipation, surprise, ownership, growth, completion, transformation and discovery—not fake scarcity, misleading countdowns, payment pressure or forced interruption.

## Kill conditions
Revise before content expansion if VEND is the only fun interaction; creatures are forgettable; duplicate feels like failure; Habitat feels like storage; Machine feels like background decoration; NEW is the only valued result; start and 10-minute screenshots look nearly identical; retention requires only adding species; or waits feel empty in real play.
