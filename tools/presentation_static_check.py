from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
scene = (ROOT / 'scenes/main/Main.tscn').read_text()
main = (ROOT / 'scripts/presentation/main.gd').read_text()
project = (ROOT / 'project.godot').read_text()

required_files = [
    'scripts/presentation/components/machine_display.gd',
    'scripts/presentation/components/capsule_display.gd',
    'scripts/presentation/components/monster_token.gd',
    'scripts/presentation/components/habitat_display.gd',
]
for rel in required_files:
    assert (ROOT / rel).exists(), rel

required_nodes = [
    'MachineDisplay', 'HabitatCanvas', 'VendButton', 'DiscoveryBar',
    'RevealOverlay', 'Capsule', 'RevealMonster', 'RevealBadge',
]
for name in required_nodes:
    assert f'name="{name}"' in scene, name
    assert f'%{name}' in main or name in {'RevealBadge'}, name

for rel in required_files:
    assert f'res://{rel}' in scene or f'res://{rel}' in main, rel

assert 'run/main_scene="res://scenes/main/Main.tscn"' in project
assert 'func _play_vend_sequence' in main
assert 'await machine_display.play_vend_motion()' in main
assert 'await capsule.play_drop' in main
assert 'await capsule.play_pop' in main
assert 'await _play_habitat_entry(monster)' in main
assert 'habitat_canvas.set_state' in main
assert 'token.set_habitat_index' in main
assert 'if vend_animating:\n        return' in main

for obsolete in ['PullButton', 'MonsterList', 'ResultName', 'DnaLabel']:
    assert obsolete not in scene, obsolete
    assert obsolete not in main, obsolete

def stripped(text: str) -> str:
    text = re.sub(r'"(?:\\.|[^"\\])*"', '""', text)
    text = re.sub(r'#.*', '', text)
    return text

for rel in ['scripts/presentation/main.gd', *required_files]:
    text = stripped((ROOT / rel).read_text())
    for a, b in [('(', ')'), ('[', ']'), ('{', '}')]:
        assert text.count(a) == text.count(b), (rel, a, text.count(a), b, text.count(b))

print('presentation_static_check: PASS')
print('presentation files:', 1 + len(required_files))
print('required nodes:', ', '.join(required_nodes))
