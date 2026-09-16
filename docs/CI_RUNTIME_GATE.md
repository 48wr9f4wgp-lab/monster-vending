# CI Runtime Gate

This repository uses GitHub Actions as the first runtime gate when local Godot is unavailable.

The workflow runs, in order:

1. Python static validators.
2. Godot 4.7.2 headless editor import to parse resources/scripts.
3. A headless main-scene smoke run for 180 iterations.

A green workflow is evidence that the project imports and starts in Godot headless mode. It is **not** evidence of touch UX, rendering quality, audio, haptics, or mobile-device performance; those still require visual/behavior verification on a target mobile device.
