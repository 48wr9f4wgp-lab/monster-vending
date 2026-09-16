from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
scene = (ROOT / "scenes/main/Main.tscn").read_text(encoding="utf-8")
script = (ROOT / "scripts/presentation/components/collection_sheet.gd").read_text(encoding="utf-8")
monsters = (ROOT / "data/monsters.json").read_text(encoding="utf-8")

checks = {
    "collection button": 'name="CollectionButton"' in scene and 'text = "COLLECTION"' in scene,
    "collection sheet node": 'name="CollectionSheet"' in scene and 'collection_sheet.gd' in scene,
    "bottom sheet connection": 'from="BottomRow/CollectionButton" to="CollectionSheet" method="toggle_sheet"' in scene,
    "two-column grid": 'grid.columns = 2' in script,
    "locked state": '"???"' in script and 'UNDISCOVERED' in script,
    "rarity display": 'rarity_label' in script and '_rarity_color' in script,
    "star display": '"★%d"' in script,
    "dna display": 'DNA  %d / %d' in script and '_dna_target' in script,
    "eight species": monsters.count('"id":') == 8,
    "debug save hidden": 'name="SaveButton"' in scene and 'name="LoadButton"' in scene and scene.count('visible = false') >= 5,
}

failed = [name for name, ok in checks.items() if not ok]
for name, ok in checks.items():
    print(f"[{'PASS' if ok else 'FAIL'}] {name}")

if failed:
    raise SystemExit("Collection static gate failed: " + ", ".join(failed))

print("Collection static gate: PASS")
