from __future__ import annotations
import json, random, statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MONSTERS = json.loads((ROOT / 'data/monsters.json').read_text())
MACHINE = json.loads((ROOT / 'data/machine_01.json').read_text())
BY_ID = {m['id']: m for m in MONSTERS}
STAR_MULT = {1: 1.0, 2: 1.5, 3: 2.2}
RARITY_RANK = {'common': 0, 'uncommon': 1, 'rare': 2, 'epic': 3, 'legendary': 4}
REP_NEW = MACHINE['reputation']['new_by_rarity']


def cost(vend_no: int) -> int:
    costs = MACHINE['vend_costs']
    idx = vend_no - 1
    if idx < len(costs):
        return int(costs[idx])
    return int(costs[-1]) + (idx - len(costs) + 1) * int(MACHINE['vend_cost_increment_after_table'])


def discovery_threshold(discovered: set[str]) -> int:
    remaining = [m for m in MONSTERS if m['id'] not in discovered]
    if not remaining:
        return 0
    rank = max(RARITY_RANK[m['rarity']] for m in remaining)
    return {4: 12, 3: 7, 2: 5}.get(rank, 4)


def pick_weighted(rng: random.Random, discovered: set[str], require_new: bool = False, tag: str = 'cute'):
    pool = []
    for m in MONSTERS:
        if require_new and m['id'] in discovered:
            continue
        w = float(m['weight']) * (float(MACHINE['dial_weight_multiplier']) if tag in m.get('tags', []) else 1.0)
        if w > 0:
            pool.append((m, w))
    if not pool and require_new:
        return pick_weighted(rng, discovered, False, tag)
    total = sum(w for _, w in pool)
    x = rng.random() * total
    c = 0.0
    for m, w in pool:
        c += w
        if x <= c:
            return m
    return pool[-1][0]


def run(seed: int):
    rng = random.Random(seed)
    coins = float(MACHINE['starting_coins'])
    t = 0.0
    vend = 0
    xp = 0
    level = 1
    rep = 0
    discovered: set[str] = set()
    star: dict[str, int] = {}
    dna: dict[str, int] = {}
    dup_since_new = 0
    blocked_seconds = 0.0
    first_rare_t = None
    first_duplicate_t = None
    first_growth_t = None
    habitat_t = None

    def income() -> float:
        return sum(BY_ID[mid]['income_per_second'] * STAR_MULT[star[mid]] for mid in discovered)

    while t < 600 and vend < 40:
        next_level = level + 1
        threshold = int(MACHINE['machine_level_xp'].get(str(next_level), 999999))
        if xp >= threshold and next_level <= 5:
            level = next_level

        next_no = vend + 1
        if next_no == 5 and level < 2:
            break

        c = cost(next_no)
        if coins < c:
            rate = income()
            if rate <= 0:
                break
            dt = (c - coins) / rate
            if t + dt > 600:
                blocked_seconds += max(0.0, 600 - t)
                t = 600
                break
            coins += rate * dt
            t += dt
            blocked_seconds += dt

        coins -= c
        vend += 1

        require_guaranteed_new = discovery_threshold(discovered) > 0 and dup_since_new >= discovery_threshold(discovered)
        if vend == 1:
            m = BY_ID['puff']
        elif vend in (2, 3):
            m = pick_weighted(rng, discovered, True)
        elif vend == 4:
            m = BY_ID['puff']
        elif vend == 5:
            m = pick_weighted(rng, discovered, True, 'cute')
        elif vend == 6:
            m = BY_ID['gobble'] if 'gobble' not in discovered else pick_weighted(rng, discovered, True)
        elif require_guaranteed_new:
            m = pick_weighted(rng, discovered, True, 'cute')
        else:
            m = pick_weighted(rng, discovered, False, 'cute')

        mid = m['id']
        is_new = mid not in discovered
        xp += 1
        if is_new:
            discovered.add(mid)
            star[mid] = 1
            dna[mid] = 0
            dup_since_new = 0
            xp += 1
            rep += int(REP_NEW[m['rarity']])
        else:
            if first_duplicate_t is None:
                first_duplicate_t = t
            dup_since_new += 1
            if star[mid] >= 3:
                xp += 1
                coins += max(1.0, c / 4.0)
            else:
                dna[mid] += 1
                req = 1 if star[mid] == 1 else 3
                if dna[mid] >= req:
                    dna[mid] -= req
                    star[mid] += 1
                    rep += 5 if star[mid] == 2 else 10
                    if first_growth_t is None:
                        first_growth_t = t

        if m['rarity'] in ('rare', 'epic', 'legendary') and first_rare_t is None:
            first_rare_t = t
        if rep >= int(MACHINE['reputation']['habitat_expand']) and habitat_t is None:
            habitat_t = t

        dt = 2.2
        coins += income() * dt
        t += dt

    return {
        'vends': vend,
        'unique': len(discovered),
        'level': level,
        'rep': rep,
        'first_rare': first_rare_t,
        'first_duplicate': first_duplicate_t,
        'first_growth': first_growth_t,
        'habitat': habitat_t,
        'blocked': blocked_seconds,
        't': t,
    }


runs = [run(i) for i in range(2000)]
vs = [r['vends'] for r in runs]
us = [r['unique'] for r in runs]
first_rare = [r['first_rare'] for r in runs if r['first_rare'] is not None]
first_dup = [r['first_duplicate'] for r in runs if r['first_duplicate'] is not None]
first_growth = [r['first_growth'] for r in runs if r['first_growth'] is not None]
habitat = [r['habitat'] for r in runs if r['habitat'] is not None]
blocked = [r['blocked'] for r in runs]

print('balance_sanity (2000 runs, 10-minute cap)')
print('vends mean/median/p10/p90:', round(statistics.mean(vs), 2), statistics.median(vs), sorted(vs)[199], sorted(vs)[1799])
print('unique mean/median:', round(statistics.mean(us), 2), statistics.median(us))
print('first duplicate median sec:', round(statistics.median(first_dup), 1))
print('first growth median sec:', round(statistics.median(first_growth), 1))
print('first rare median sec:', round(statistics.median(first_rare), 1))
print('habitat-ready median sec:', round(statistics.median(habitat), 1))
print('coin-blocked median sec:', round(statistics.median(blocked), 1))
print('vend range:', min(vs), max(vs))

assert 10 <= statistics.median(vs) <= 13, '10-minute VEND median outside target'
assert 5 <= statistics.median(us) <= 7, '10-minute unique species outside target'
assert 120 <= statistics.median(first_dup) <= 240, 'first duplicate outside 2-4 minute target'
assert 120 <= statistics.median(first_growth) <= 240, 'first growth outside 2-4 minute target'
assert 240 <= statistics.median(first_rare) <= 420, 'first rare outside 4-7 minute target'
assert statistics.median(habitat) <= 600, 'habitat expansion not ready within 10 minutes'
print('balance_sanity: PASS')
