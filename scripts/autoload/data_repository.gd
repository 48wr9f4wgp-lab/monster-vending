extends Node

const MONSTER_DATA_PATH := "res://data/monsters.json"
const MACHINE_DATA_PATH := "res://data/machine_01.json"

var monsters: Array[Dictionary] = []
var monster_by_id: Dictionary = {}
var machine: Dictionary = {}

func _ready() -> void:
    _load_monsters()
    _load_machine()
    _validate_data()

func _load_json(path: String) -> Variant:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("MONSTER VENDING: failed to open %s" % path)
        return null
    return JSON.parse_string(file.get_as_text())

func _load_monsters() -> void:
    var parsed := _load_json(MONSTER_DATA_PATH)
    if not (parsed is Array):
        push_error("MONSTER VENDING: monster data must be an array")
        return
    monsters.clear()
    monster_by_id.clear()
    for entry in parsed:
        if entry is Dictionary and entry.has("id"):
            var monster: Dictionary = entry
            monsters.append(monster)
            monster_by_id[String(monster["id"])] = monster

func _load_machine() -> void:
    var parsed := _load_json(MACHINE_DATA_PATH)
    if not (parsed is Dictionary):
        push_error("MONSTER VENDING: machine data must be an object")
        return
    machine = parsed

func _validate_data() -> void:
    if monsters.size() != 8:
        push_error("MONSTER VENDING: vertical slice requires exactly 8 species")
    var seen: Dictionary = {}
    for monster in monsters:
        var monster_id := String(monster.get("id", ""))
        if monster_id.is_empty() or seen.has(monster_id):
            push_error("MONSTER VENDING: invalid/duplicate monster id %s" % monster_id)
        seen[monster_id] = true
        if float(monster.get("income_per_second", -1.0)) < 0.0:
            push_error("MONSTER VENDING: negative income for %s" % monster_id)
    if machine.is_empty():
        push_error("MONSTER VENDING: machine_01 data missing")

func get_monster(monster_id: String) -> Dictionary:
    return monster_by_id.get(monster_id, {})

func get_vend_cost(vend_number: int) -> int:
    if vend_number <= 1:
        return 0
    var costs: Array = machine.get("vend_costs", [])
    var index := vend_number - 1
    if index >= 0 and index < costs.size():
        return int(costs[index])
    if costs.is_empty():
        return 0
    var last_cost := int(costs.back())
    var extra_vends := index - (costs.size() - 1)
    return last_cost + extra_vends * int(machine.get("vend_cost_increment_after_table", 20))

func machine_xp_required(level: int) -> int:
    var levels: Dictionary = machine.get("machine_level_xp", {})
    return int(levels.get(str(level), 999999))

func reputation_for_new(rarity: String) -> int:
    var reputation: Dictionary = machine.get("reputation", {})
    var by_rarity: Dictionary = reputation.get("new_by_rarity", {})
    return int(by_rarity.get(rarity, 0))

func reputation_for_star(star: int) -> int:
    var reputation: Dictionary = machine.get("reputation", {})
    return int(reputation.get("star_%d" % star, 0))

func habitat_expand_reputation() -> int:
    var reputation: Dictionary = machine.get("reputation", {})
    return int(reputation.get("habitat_expand", 45))

func dial_weight_multiplier() -> float:
    return float(machine.get("dial_weight_multiplier", 1.5))
