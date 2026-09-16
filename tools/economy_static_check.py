from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[1]
machine = json.loads((ROOT / 'data/machine_01.json').read_text())
game_state = (ROOT / 'scripts/autoload/game_state.gd').read_text()
save_service = (ROOT / 'scripts/autoload/save_service.gd').read_text()
analytics = (ROOT / 'scripts/autoload/analytics_service.gd').read_text()
main = (ROOT / 'scripts/presentation/main.gd').read_text()

for token in [
    'func seconds_until_vend()',
    'func offline_reward_for_seconds',
    'func apply_offline_income',
    'offline_income_multiplier',
    'offline_vend_cap',
]:
    assert token in game_state, token

assert '"last_save_unix"' in save_service
assert 'offline_income_applied' in analytics
assert 'economy_checkpoint' in analytics
assert 'coins_blocked_seconds' in main
assert 'ECONOMY_CHECKPOINTS' in main

rate = 100.0
away = float(machine['offline_cap_seconds']) * 2.0
raw = rate * min(away, float(machine['offline_cap_seconds'])) * float(machine['offline_income_multiplier'])
reference_cost = int(machine['vend_costs'][6])
cap = reference_cost * int(machine['offline_vend_cap'])
reward = min(raw, cap)
assert reward == cap, (reward, cap)

print('economy_static_check: PASS')
print('offline cap example:', reward)
print('runtime checkpoints: 60s / 300s / 600s')
