# MONSTER VENDING — Vertical Slice Final Spec Patch v1.0.1

Date: 2026-09-16
Status: Canonical patch over v1.0 where values conflict.

## Machine Lv2 XP correction
`machine_level_xp[2]` changes from **11 XP** to **7 XP**.

Reason:
- Protected Vend 1: +2 XP (vend + NEW)
- Vend 2: +2 XP
- Vend 3: +2 XP
- Vend 4: +1 XP (duplicate)
- Total after Vend 4 = 7 XP

This makes the intended FTUE order internally consistent:
`First Duplicate -> Machine Lv2 Upgrade -> Vending Dial -> Vend 5`

The previous 11 XP threshold could only be reached after Vend 6 and contradicted the locked FTUE flow.

## Economy timing correction (v1.0.2 balance patch)
The original vend-cost table produced a simulated median of ~16 VENDs in 10 minutes, above the locked 10–13 target.

Vertical Slice test curve is therefore changed to:
`[0, 20, 60, 160, 220, 240, 250, 260, 270, 280, 290, 300, 310]`

After the table, cost increases by **+10** per VEND.

2000-run offline sanity simulation:
- median VENDs / 10 min: ~11
- median first duplicate: ~2.4 min
- median first Rare: ~4.1 min

This is a test-balance patch. Runtime playtesting may supersede it.
