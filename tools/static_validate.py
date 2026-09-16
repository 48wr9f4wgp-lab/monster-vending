from __future__ import annotations
import json
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
monsters = json.loads((ROOT / "data/monsters.json").read_text())
machine = json.loads((ROOT / "data/machine_01.json").read_text())

assert len(monsters) == 8, len(monsters)
ids = [m["id"] for m in monsters]
assert ids == ["puff", "bloop", "shroomy", "pricky", "peeko", "gobble", "sparky", "mimic"], ids
assert len(set(ids)) == 8

rarity_totals = defaultdict(float)
for monster in monsters:
    rarity_totals[monster["rarity"]] += float(monster["weight"])
expected = {"common":52.0,"uncommon":28.0,"rare":13.0,"epic":5.5,"legendary":1.5}
for rarity, target in expected.items():
    assert abs(rarity_totals[rarity] - target) < 0.00001, (rarity, rarity_totals[rarity], target)
assert abs(sum(rarity_totals.values()) - 100.0) < 0.00001

assert machine["starting_coins"] == 10.0
assert machine["vend_costs"][:6] == [0,20,60,160,220,240]
assert machine["machine_level_xp"]["2"] == 7
assert machine["habitat_capacity"] == {"start":4,"expanded":8}
assert machine["protected_pulls"] == 6

assert 2 + 2 + 2 + 1 == machine["machine_level_xp"]["2"]

print("static_validate: PASS")
print("species:", ", ".join(ids))
print("rarity totals:", dict(rarity_totals))
print("lv2_xp:", machine["machine_level_xp"]["2"])
