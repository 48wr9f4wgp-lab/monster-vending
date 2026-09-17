extends Node

signal state_changed
signal monster_revealed(monster: Dictionary, is_new: bool, is_tutorial_pull: bool)
signal monster_grew(monster_id: String, old_star: int, new_star: int)
signal machine_upgrade_ready(level: int)
signal machine_upgraded(old_level: int, new_level: int)
signal habitat_expanded(old_capacity: int, new_capacity: int)

const MAX_STAR := 3
const DIAL_OPTIONS := ["cute", "weird", "wild"]

var coins: float = 10.0
var vend_count: int = 0
var machine_level: int = 1
var machine_xp: int = 0
var reputation: int = 0
var habitat_capacity_value: int = 4
var selected_dial: String = "cute"
var selected_monster_id: String = ""
var discovered_species: Dictionary = {}
var monster_star_levels: Dictionary = {}
var monster_dna: Dictionary = {}
var discovery_duplicates: int = 0
var last_offline_reward: float = 0.0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    if not DataRepository.machine.is_empty():
        reset_state(false)

func reset_state(emit_change: bool = true) -> void:
    coins = float(DataRepository.machine.get("starting_coins", 10.0))
    vend_count = 0
    machine_level = 1
    machine_xp = 0
    reputation = 0
    habitat_capacity_value = int(DataRepository.machine.get("habitat_capacity", {}).get("start", 4))
    selected_dial = "cute"
    selected_monster_id = ""
    discovered_species.clear()
    monster_star_levels.clear()
    monster_dna.clear()
    discovery_duplicates = 0
    last_offline_reward = 0.0
    if emit_change:
        state_changed.emit()

func unique_monster_count() -> int:
    return discovered_species.size()

func habitat_capacity() -> int:
    return habitat_capacity_value

func current_vend_number() -> int:
    return vend_count + 1

func current_vend_cost() -> int:
    return DataRepository.get_vend_cost(current_vend_number())

func can_vend() -> bool:
    if DataRepository.monsters.is_empty():
        return false
    if current_vend_number() == 5 and machine_level < 2:
        return false
    return coins + 0.0001 >= float(current_vend_cost())

func passive_income_per_second() -> float:
    var total := 0.0
    for monster_id in discovered_species.keys():
        var definition := DataRepository.get_monster(String(monster_id))
        var base_income := float(definition.get("income_per_second", 0.0))
        var star := int(monster_star_levels.get(monster_id, 1))
        total += base_income * _star_income_multiplier(star)
    return total

func _star_income_multiplier(star: int) -> float:
    match star:
        2:
            return 1.5
        3:
            return 2.2
        _:
            return 1.0

func vend_monster() -> Dictionary:
    if not can_vend():
        return {}
    var vend_number := current_vend_number()
    var cost := current_vend_cost()
    coins -= float(cost)
    vend_count += 1
    var tutorial_pull := vend_number <= int(DataRepository.machine.get("protected_pulls", 6))
    AnalyticsService.track("vend_started", {"vend_number": vend_number, "cost": cost, "tutorial_pull": tutorial_pull})
    var monster := _pick_for_vend(vend_number)
    if monster.is_empty():
        coins += float(cost)
        vend_count -= 1
        return {}
    var monster_id := String(monster.get("id", ""))
    var is_new := not discovered_species.has(monster_id)
    selected_monster_id = monster_id
    machine_xp += 1
    if is_new:
        discovered_species[monster_id] = true
        monster_star_levels[monster_id] = 1
        monster_dna[monster_id] = 0
        discovery_duplicates = 0
        machine_xp += 1
        reputation += DataRepository.reputation_for_new(String(monster.get("rarity", "common")))
    else:
        _apply_duplicate(monster_id)
    AnalyticsService.track("monster_revealed", {"species_id": monster_id, "rarity": String(monster.get("rarity", "common")), "is_new": is_new, "is_duplicate": not is_new, "tutorial_pull": tutorial_pull})
    monster_revealed.emit(monster, is_new, tutorial_pull)
    _emit_upgrade_ready_if_needed()
    state_changed.emit()
    return {"monster": monster, "is_new": is_new, "tutorial_pull": tutorial_pull}

func _pick_for_vend(vend_number: int) -> Dictionary:
    match vend_number:
        1:
            return DataRepository.get_monster("puff")
        2, 3:
            return _weighted_pick(true, "")
        4:
            return DataRepository.get_monster("puff")
        5:
            return _weighted_pick(true, selected_dial)
        6:
            var gobble := DataRepository.get_monster("gobble")
            if not discovered_species.has("gobble"):
                return gobble
            return _weighted_pick(true, "")
        _:
            if is_discovery_guaranteed():
                return _weighted_pick(true, selected_dial)
            return _weighted_pick(false, selected_dial)

func _weighted_pick(require_new: bool, preferred_tag: String) -> Dictionary:
    var pool: Array[Dictionary] = []
    var total_weight := 0.0
    for monster in DataRepository.monsters:
        var monster_id := String(monster.get("id", ""))
        if require_new and discovered_species.has(monster_id):
            continue
        var weight := float(monster.get("weight", 0.0))
        if not preferred_tag.is_empty() and preferred_tag in monster.get("tags", []):
            weight *= DataRepository.dial_weight_multiplier()
        if weight <= 0.0:
            continue
        pool.append({"monster": monster, "weight": weight})
        total_weight += weight
    if pool.is_empty():
        if require_new:
            return _weighted_pick(false, preferred_tag)
        return {}
    var roll := rng.randf_range(0.0, total_weight)
    var cursor := 0.0
    for item in pool:
        cursor += float(item["weight"])
        if roll <= cursor:
            return item["monster"]
    return pool.back()["monster"]

func _apply_duplicate(monster_id: String) -> void:
    discovery_duplicates += 1
    var star := int(monster_star_levels.get(monster_id, 1))
    if star >= MAX_STAR:
        machine_xp += 1
        coins += float(max(1, current_vend_cost() / 4))
        return
    monster_dna[monster_id] = int(monster_dna.get(monster_id, 0)) + 1
    _apply_available_growth(monster_id)

func _apply_available_growth(monster_id: String) -> void:
    var star := int(monster_star_levels.get(monster_id, 1))
    while star < MAX_STAR:
        var required := 1 if star == 1 else 3
        var dna := int(monster_dna.get(monster_id, 0))
        if dna < required:
            break
        monster_dna[monster_id] = dna - required
        var old_star := star
        star += 1
        monster_star_levels[monster_id] = star
        reputation += DataRepository.reputation_for_star(star)
        AnalyticsService.track("monster_growth", {"species_id": monster_id, "old_star": old_star, "new_star": star})
        monster_grew.emit(monster_id, old_star, star)

func set_vending_dial(dial: String) -> bool:
    var normalized := dial.to_lower()
    if machine_level < 2 or normalized not in DIAL_OPTIONS:
        return false
    selected_dial = normalized
    AnalyticsService.track("dial_used", {"dial_type": selected_dial})
    state_changed.emit()
    return true

func can_upgrade_machine() -> bool:
    if machine_level >= 5:
        return false
    return machine_xp >= DataRepository.machine_xp_required(machine_level + 1)

func upgrade_machine() -> bool:
    if not can_upgrade_machine():
        return false
    var old_level := machine_level
    machine_level += 1
    AnalyticsService.track("machine_upgrade", {"old_level": old_level, "new_level": machine_level})
    machine_upgraded.emit(old_level, machine_level)
    state_changed.emit()
    return true

func _emit_upgrade_ready_if_needed() -> void:
    if can_upgrade_machine():
        machine_upgrade_ready.emit(machine_level + 1)

func can_expand_habitat() -> bool:
    var expanded := int(DataRepository.machine.get("habitat_capacity", {}).get("expanded", 8))
    return habitat_capacity_value < expanded and reputation >= DataRepository.habitat_expand_reputation()

func expand_habitat() -> bool:
    if not can_expand_habitat():
        return false
    var old_capacity := habitat_capacity_value
    habitat_capacity_value = int(DataRepository.machine.get("habitat_capacity", {}).get("expanded", 8))
    AnalyticsService.track("habitat_expand", {"old_capacity": old_capacity, "new_capacity": habitat_capacity_value})
    habitat_expanded.emit(old_capacity, habitat_capacity_value)
    state_changed.emit()
    return true

func discovery_threshold() -> int:
    var undiscovered: Array[Dictionary] = []
    for monster in DataRepository.monsters:
        if not discovered_species.has(String(monster.get("id", ""))):
            undiscovered.append(monster)
    if undiscovered.is_empty():
        return 0
    var highest_rank := 0
    for monster in undiscovered:
        highest_rank = max(highest_rank, _rarity_rank(String(monster.get("rarity", "common"))))
    match highest_rank:
        4:
            return 12
        3:
            return 7
        2:
            return 5
        _:
            return 4

func is_discovery_guaranteed() -> bool:
    var threshold := discovery_threshold()
    return threshold > 0 and discovery_duplicates >= threshold

func _rarity_rank(rarity: String) -> int:
    match rarity:
        "legendary":
            return 4
        "epic":
            return 3
        "rare":
            return 2
        "uncommon":
            return 1
        _:
            return 0

func seconds_until_vend() -> float:
    var missing := maxf(0.0, float(current_vend_cost()) - coins)
    if missing <= 0.0:
        return 0.0
    var rate := passive_income_per_second()
    if rate <= 0.0:
        return -1.0
    return missing / rate

func offline_reward_for_seconds(away_seconds: float) -> float:
    var safe_away := maxf(0.0, away_seconds)
    var cap_seconds := float(DataRepository.machine.get("offline_cap_seconds", 28800))
    var multiplier := float(DataRepository.machine.get("offline_income_multiplier", 0.35))
    var effective_seconds := minf(safe_away, cap_seconds)
    var raw_reward := passive_income_per_second() * effective_seconds * multiplier
    var vend_cap_count := int(DataRepository.machine.get("offline_vend_cap", 3))
    var reference_cost := current_vend_cost()
    if reference_cost <= 0:
        reference_cost = DataRepository.get_vend_cost(2)
    var reward_cap := float(maxi(0, reference_cost * vend_cap_count))
    return minf(raw_reward, reward_cap)

func apply_offline_income(away_seconds: float) -> float:
    var reward := offline_reward_for_seconds(away_seconds)
    last_offline_reward = reward
    if reward <= 0.0:
        return 0.0
    coins += reward
    AnalyticsService.track("offline_income_applied", {"away_seconds": int(maxf(0.0, away_seconds)), "reward": reward, "income_rate": passive_income_per_second()})
    state_changed.emit()
    return reward

func tick_passive_income(delta_seconds: float = 1.0) -> void:
    var amount: float = passive_income_per_second() * maxf(0.0, delta_seconds)
    if amount <= 0.0:
        return
    coins += amount
    state_changed.emit()
