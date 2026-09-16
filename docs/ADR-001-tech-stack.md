# ADR-001 — MONSTER VENDING Tech Stack

Status: Accepted for Vertical Slice
Date: 2026-09-16

## Decision
Use Godot 4.7.2 stable + GDScript for the Vertical Slice and initial production baseline.

## Context
MONSTER VENDING is a portrait iOS/Android creature-collection / light-management game. The slice is offline single-player with no backend, no multiplayer, no heavy native SDK requirement, and a small-team production target. It needs strong UI, animation, particles, audio/haptics, light 2D/2.5D presentation, local save and analytics adapters.

## Options considered
### Godot 4.7.2 stable — selected
- Fits small-team 2D to medium-3D production.
- Fast iteration and data-driven GDScript workflow.
- Cross-platform mobile export.
- No engine licensing dependency for the core product.

### Unity — viable fallback
Prefer if later requirements materially shift toward a large mobile SDK stack, advanced commercial middleware, or a substantially larger 3D production pipeline.

### Phaser / Web stack — rejected for production baseline
Useful for lightweight web prototypes, but native mobile presentation, haptics, app lifecycle and future 2.5D/3D character presentation are more direct in Godot.

## Renderer
Vertical Slice defaults to `gl_compatibility` to bias toward broad mobile compatibility. Re-evaluate Forward+/Mobile only if the final art pipeline requires it and target-device profiling proves it safe.

## Language
GDScript for gameplay and presentation. Platform-specific native bridges must remain behind adapters if added later.

## Consequences
- Game/domain state must not depend directly on scene visuals.
- Analytics and monetization must be adapter-based.
- Save data starts with `schema_version`.
- Visual monster agents may be pooled/simplified independently of economy calculations.
- Engine upgrades require version-control backup and regression verification.
