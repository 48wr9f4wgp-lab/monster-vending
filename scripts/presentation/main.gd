extends Control

const MONSTER_TOKEN_SCRIPT := preload("res://scripts/presentation/components/monster_token.gd")

@onready var coins_label: Label = %CoinsLabel
@onready var machine_label: Label = %MachineLabel
@onready var collection_label: Label = %CollectionLabel
@onready var habitat_label: Label = %HabitatLabel
@onready var income_label: Label = %IncomeLabel
@onready var discovery_label: Label = %DiscoveryLabel
@onready var discovery_bar: ProgressBar = %DiscoveryBar
@onready var vend_button: Button = %VendButton
@onready var machine_button: Button = %MachineButton
@onready var habitat_button: Button = %HabitatButton
@onready var dial_row: HBoxContainer = %DialRow
@onready var cute_button: Button = %CuteButton
@onready var weird_button: Button = %WeirdButton
@onready var wild_button: Button = %WildButton
@onready var habitat_canvas: HabitatDisplay = %HabitatCanvas
@onready var empty_habitat_label: Label = %EmptyHabitatLabel
@onready var machine_display: MachineDisplay = %MachineDisplay
@onready var reveal_overlay: Control = %RevealOverlay
@onready var reveal_dim: ColorRect = %Dim
@onready var capsule: CapsuleDisplay = %Capsule
@onready var reveal_monster: MonsterToken = %RevealMonster
@onready var reveal_badge: Label = %RevealBadge
@onready var reveal_name: Label = %RevealName
@onready var reveal_meta: Label = %RevealMeta
@onready var toast: PanelContainer = %Toast
@onready var toast_label: Label = %ToastLabel
@onready var income_timer: Timer = %IncomeTimer

var vend_animating: bool = false
var toast_tween: Tween
var session_seconds: float = 0.0
var coins_blocked_seconds: float = 0.0
var economy_checkpoint_index: int = 0
const ECONOMY_CHECKPOINTS := [60.0, 300.0, 600.0]

func _ready() -> void:
    GameState.state_changed.connect(_refresh)
    GameState.monster_grew.connect(_on_monster_grew)
    GameState.machine_upgrade_ready.connect(_on_machine_upgrade_ready)
    GameState.machine_upgraded.connect(_on_machine_upgraded)
    GameState.habitat_expanded.connect(_on_habitat_expanded)

    vend_button.pressed.connect(_on_vend_pressed)
    machine_button.pressed.connect(_on_machine_upgrade_pressed)
    habitat_button.pressed.connect(_on_habitat_expand_pressed)
    cute_button.pressed.connect(_on_dial_pressed.bind("cute"))
    weird_button.pressed.connect(_on_dial_pressed.bind("weird"))
    wild_button.pressed.connect(_on_dial_pressed.bind("wild"))
    %SaveButton.pressed.connect(_on_save_pressed)
    %LoadButton.pressed.connect(_on_load_pressed)
    income_timer.timeout.connect(_on_income_tick)

    reveal_overlay.visible = false
    toast.visible = false
    AnalyticsService.track("session_start", {"save_version": SaveService.SCHEMA_VERSION})
    _refresh()

func _process(delta: float) -> void:
    session_seconds += maxf(0.0, delta)
    if _is_coin_blocked():
        coins_blocked_seconds += maxf(0.0, delta)

    while economy_checkpoint_index < ECONOMY_CHECKPOINTS.size() and session_seconds >= float(ECONOMY_CHECKPOINTS[economy_checkpoint_index]):
        _emit_economy_checkpoint(int(ECONOMY_CHECKPOINTS[economy_checkpoint_index]))
        economy_checkpoint_index += 1

func _exit_tree() -> void:
    AnalyticsService.track("session_end", {
        "session_seconds": int(session_seconds),
        "total_vends": GameState.vend_count,
        "species_count": GameState.unique_monster_count(),
        "coins_blocked_seconds": int(coins_blocked_seconds)
    })

func _on_vend_pressed() -> void:
    if vend_animating:
        return
    if not GameState.can_vend():
        if GameState.current_vend_number() == 5 and GameState.machine_level < 2:
            _show_toast("UPGRADE THE MACHINE · Lv2 unlocks the Dial")
        else:
            var missing := maxi(0, GameState.current_vend_cost() - int(floor(GameState.coins)))
            _show_toast("NEED %d MORE COINS" % missing)
        return

    vend_animating = true
    vend_button.disabled = true
    _light_haptic()

    var result := GameState.vend_monster()
    if result.is_empty():
        vend_animating = false
        _refresh()
        return

    var monster: Dictionary = result.get("monster", {})
    var is_new := bool(result.get("is_new", false))
    var tutorial_pull := bool(result.get("tutorial_pull", false))
    if GameState.vend_count == 1:
        AnalyticsService.track("first_vend", {"vend_number": 1})
    await _play_vend_sequence(monster, is_new, tutorial_pull)
    vend_animating = false
    _refresh()

func _play_vend_sequence(monster: Dictionary, is_new: bool, tutorial_pull: bool) -> void:
    var rarity := String(monster.get("rarity", "common"))
    var monster_id := String(monster.get("id", ""))

    await machine_display.play_vend_motion()

    reveal_overlay.visible = true
    reveal_dim.modulate.a = 0.0
    capsule.visible = true
    capsule.modulate.a = 1.0
    capsule.scale = Vector2.ONE
    capsule.set_rarity(rarity)
    capsule.set_glow(0.0)
    capsule.set_opened(0.0)
    reveal_monster.visible = false
    reveal_badge.visible = false
    reveal_name.visible = false
    reveal_meta.visible = false

    var dim_in := create_tween()
    dim_in.tween_property(reveal_dim, "modulate:a", 1.0, 0.12)

    await capsule.play_drop(Vector2(260, 365), Vector2(260, 500))
    _medium_haptic()
    await capsule.play_shake()
    await get_tree().create_timer(0.11).timeout
    await capsule.play_pop()

    reveal_monster.configure(monster, int(GameState.monster_star_levels.get(monster_id, 1)))
    reveal_monster.position = Vector2(240, 420)
    reveal_monster.rotation = 0.0
    reveal_monster.scale = Vector2.ONE
    reveal_monster.modulate = Color.WHITE
    reveal_monster.visible = true

    reveal_badge.text = "NEW!" if is_new else "DUPLICATE!"
    reveal_badge.visible = true
    reveal_name.text = String(monster.get("name", "UNKNOWN"))
    reveal_name.visible = true
    if is_new:
        reveal_meta.text = String(rarity).to_upper() + (" · FTUE" if tutorial_pull else "")
    else:
        var star := int(GameState.monster_star_levels.get(monster_id, 1))
        var dna := int(GameState.monster_dna.get(monster_id, 0))
        reveal_meta.text = "%s · ★%d · DNA %d" % [rarity.to_upper(), star, dna]
    reveal_meta.visible = true

    _rarity_haptic(rarity)
    await reveal_monster.play_spawn()
    await get_tree().create_timer(_reveal_hold_for(rarity)).timeout

    if is_new:
        await _play_habitat_entry(monster)
    else:
        await _play_duplicate_absorb(monster_id)

    var fade := create_tween()
    fade.tween_property(reveal_dim, "modulate:a", 0.0, 0.12)
    await fade.finished
    reveal_overlay.visible = false
    _refresh_habitat(false)

func _play_habitat_entry(monster: Dictionary) -> void:
    reveal_badge.visible = false
    reveal_name.visible = false
    reveal_meta.visible = false

    var start_global := reveal_monster.global_position
    var monster_id := String(monster.get("id", ""))
    var slot_index := _visible_index_for(monster_id)
    var target_local := _habitat_slot_position(maxi(0, slot_index))
    var target_global := habitat_canvas.global_position + target_local

    var flying: MonsterToken = MONSTER_TOKEN_SCRIPT.new()
    flying.custom_minimum_size = Vector2(104, 104)
    flying.size = Vector2(104, 104)
    flying.configure(monster, int(GameState.monster_star_levels.get(monster_id, 1)))
    add_child(flying)
    flying.global_position = start_global + Vector2(68, 68)
    flying.scale = Vector2(1.15, 1.15)
    reveal_monster.visible = false

    var travel := create_tween()
    travel.set_parallel(true)
    travel.tween_property(flying, "global_position", target_global, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)
    travel.tween_property(flying, "scale", Vector2(0.92, 0.92), 0.38)
    travel.tween_property(flying, "rotation", deg_to_rad(7.0), 0.18)
    await travel.finished
    _light_haptic()
    flying.queue_free()
    _refresh_habitat(true, monster_id)
    await get_tree().create_timer(0.12).timeout

func _play_duplicate_absorb(monster_id: String) -> void:
    var target := _find_habitat_token(monster_id)
    if target == null:
        reveal_monster.visible = false
        return

    reveal_badge.text = "DNA → GROWTH"
    reveal_badge.visible = true
    reveal_name.visible = false
    reveal_meta.visible = false

    var start := reveal_monster.global_position
    var end := target.global_position
    var absorb := create_tween()
    absorb.set_parallel(true)
    absorb.tween_property(reveal_monster, "global_position", end, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    absorb.tween_property(reveal_monster, "scale", Vector2(0.12, 0.12), 0.32)
    absorb.tween_property(reveal_monster, "modulate:a", 0.15, 0.32)
    await absorb.finished
    reveal_monster.visible = false
    target.set_star(int(GameState.monster_star_levels.get(monster_id, 1)))
    await target.play_reaction()
    _medium_haptic()

func _on_monster_grew(monster_id: String, old_star: int, new_star: int) -> void:
    var definition := DataRepository.get_monster(monster_id)
    _show_toast("%s GREW! · ★%d → ★%d" % [String(definition.get("name", monster_id)), old_star, new_star])

func _on_machine_upgrade_ready(level: int) -> void:
    _show_toast("MACHINE LV%d READY" % level)

func _on_machine_upgraded(old_level: int, new_level: int) -> void:
    machine_display.set_machine_level(new_level)
    await machine_display.play_upgrade(old_level, new_level)
    _medium_haptic()
    _show_toast("MACHINE UPGRADED · LV%d" % new_level)

func _on_habitat_expanded(old_capacity: int, new_capacity: int) -> void:
    _medium_haptic()
    habitat_canvas.set_state(new_capacity, GameState.reputation, GameState.unique_monster_count(), GameState.passive_income_per_second())
    await habitat_canvas.play_expand()
    _refresh_habitat(false)
    _show_toast("HABITAT EXPANDED · %d → %d" % [old_capacity, new_capacity])

func _on_machine_upgrade_pressed() -> void:
    if vend_animating:
        return
    if not GameState.upgrade_machine():
        var required := DataRepository.machine_xp_required(GameState.machine_level + 1)
        _show_toast("MACHINE NOT READY · XP %d/%d" % [GameState.machine_xp, required])

func _on_habitat_expand_pressed() -> void:
    if vend_animating:
        return
    if not GameState.expand_habitat():
        _show_toast("EXPANSION · REP %d/%d" % [GameState.reputation, DataRepository.habitat_expand_reputation()])

func _on_dial_pressed(dial: String) -> void:
    if GameState.set_vending_dial(dial):
        _light_haptic()
        _show_toast("DIAL · %s · ×%.1f WEIGHT" % [dial.to_upper(), DataRepository.dial_weight_multiplier()])
    else:
        _show_toast("DIAL LOCKED · MACHINE LV2")

func _on_save_pressed() -> void:
    _show_toast("SAVED" if SaveService.save_game() else "SAVE FAILED")

func _on_load_pressed() -> void:
    if SaveService.load_game():
        if GameState.last_offline_reward >= 1.0:
            _show_toast("WELCOME BACK · +%d COINS" % int(floor(GameState.last_offline_reward)))
        else:
            _show_toast("LOADED")
        _refresh_habitat(false)
    else:
        _show_toast("NO VALID SAVE")

func _on_income_tick() -> void:
    GameState.tick_passive_income(income_timer.wait_time)

func _refresh() -> void:
    if vend_animating:
        return
    coins_label.text = "COINS  %d" % int(floor(GameState.coins))
    machine_label.text = "MACHINE  LV%d" % GameState.machine_level
    collection_label.text = "%d / 8" % GameState.unique_monster_count()
    income_label.text = "+%.2f/s" % GameState.passive_income_per_second()
    habitat_label.text = "HABITAT  %d / %d" % [GameState.unique_monster_count(), GameState.habitat_capacity()]
    habitat_canvas.set_state(GameState.habitat_capacity(), GameState.reputation, GameState.unique_monster_count(), GameState.passive_income_per_second())
    machine_display.set_machine_level(GameState.machine_level)

    var cost := GameState.current_vend_cost()
    vend_button.text = "VEND · FREE" if cost == 0 else "VEND · %d" % cost
    vend_button.disabled = vend_animating or not GameState.can_vend()

    var threshold := GameState.discovery_threshold()
    discovery_bar.max_value = float(maxi(1, threshold))
    discovery_bar.value = float(GameState.discovery_duplicates)
    if threshold <= 0:
        discovery_label.text = "MACHINE MASTERED"
    elif GameState.is_discovery_guaranteed():
        discovery_label.text = "NEW GUARANTEED"
    else:
        discovery_label.text = "DISCOVERY  %d / %d" % [GameState.discovery_duplicates, threshold]

    if GameState.machine_level >= 5:
        machine_button.text = "MACHINE MAX"
        machine_button.disabled = true
    else:
        var required := DataRepository.machine_xp_required(GameState.machine_level + 1)
        machine_button.text = "UPGRADE LV%d · %d/%d XP" % [GameState.machine_level + 1, GameState.machine_xp, required]
        machine_button.disabled = vend_animating or not GameState.can_upgrade_machine()

    habitat_button.text = "EXPAND · REP %d/%d" % [GameState.reputation, DataRepository.habitat_expand_reputation()]
    habitat_button.disabled = vend_animating or not GameState.can_expand_habitat()

    dial_row.visible = GameState.machine_level >= 2
    cute_button.disabled = vend_animating or GameState.selected_dial == "cute"
    weird_button.disabled = vend_animating or GameState.selected_dial == "weird"
    wild_button.disabled = vend_animating or GameState.selected_dial == "wild"

    _refresh_habitat(false)

func _refresh_habitat(animate_spawn: bool, spawn_monster_id: String = "") -> void:
    for child in habitat_canvas.get_children():
        if child == empty_habitat_label:
            continue
        habitat_canvas.remove_child(child)
        child.queue_free()

    empty_habitat_label.visible = GameState.discovered_species.is_empty()
    if GameState.discovered_species.is_empty():
        return

    var visible_index := 0
    for monster in DataRepository.monsters:
        var monster_id := String(monster.get("id", ""))
        if not GameState.discovered_species.has(monster_id):
            continue
        var token: MonsterToken = MONSTER_TOKEN_SCRIPT.new()
        token.name = "Monster_%s" % monster_id
        token.custom_minimum_size = Vector2(104, 104)
        token.size = Vector2(104, 104)
        token.position = _habitat_slot_position(visible_index)
        token.set_habitat_index(visible_index)
        token.configure(monster, int(GameState.monster_star_levels.get(monster_id, 1)))
        habitat_canvas.add_child(token)
        if animate_spawn and monster_id == spawn_monster_id:
            token.play_spawn()
        visible_index += 1

func _habitat_slot_position(index: int) -> Vector2:
    var cols := 4
    var rows := 1 if GameState.habitat_capacity() <= 4 else 2
    var width := maxf(600.0, habitat_canvas.size.x)
    var height := maxf(230.0, habitat_canvas.size.y)
    var cell_w := width / float(cols)
    var cell_h := height / float(rows)
    var col := index % cols
    var row := index / cols
    return Vector2(col * cell_w + (cell_w - 104.0) * 0.5, row * cell_h + (cell_h - 104.0) * 0.5)

func _visible_index_for(monster_id: String) -> int:
    var index := 0
    for monster in DataRepository.monsters:
        var id := String(monster.get("id", ""))
        if not GameState.discovered_species.has(id):
            continue
        if id == monster_id:
            return index
        index += 1
    return maxi(0, index - 1)

func _find_habitat_token(monster_id: String) -> MonsterToken:
    var node := habitat_canvas.get_node_or_null("Monster_%s" % monster_id)
    if node is MonsterToken:
        return node
    return null

func _is_coin_blocked() -> bool:
    if vend_animating:
        return false
    if GameState.current_vend_number() == 5 and GameState.machine_level < 2:
        return false
    var cost := GameState.current_vend_cost()
    return cost > 0 and GameState.coins + 0.0001 < float(cost)

func _emit_economy_checkpoint(seconds: int) -> void:
    AnalyticsService.track("economy_checkpoint", {
        "checkpoint_seconds": seconds,
        "coins": GameState.coins,
        "vend_count": GameState.vend_count,
        "species_count": GameState.unique_monster_count(),
        "income_per_second": GameState.passive_income_per_second(),
        "next_vend_cost": GameState.current_vend_cost(),
        "seconds_until_vend": GameState.seconds_until_vend(),
        "coins_blocked_seconds": coins_blocked_seconds
    })

func _show_toast(message: String) -> void:
    toast_label.text = message
    toast.visible = true
    toast.modulate.a = 1.0
    if toast_tween != null and toast_tween.is_valid():
        toast_tween.kill()
    toast_tween = create_tween()
    toast_tween.tween_interval(1.0)
    toast_tween.tween_property(toast, "modulate:a", 0.0, 0.18)
    toast_tween.tween_callback(_hide_toast)

func _hide_toast() -> void:
    toast.visible = false

func _reveal_hold_for(rarity: String) -> float:
    match rarity:
        "legendary": return 0.85
        "epic": return 0.68
        "rare": return 0.55
        _: return 0.38

func _light_haptic() -> void:
    if OS.has_feature("mobile"):
        Input.vibrate_handheld(18)

func _medium_haptic() -> void:
    if OS.has_feature("mobile"):
        Input.vibrate_handheld(32)

func _rarity_haptic(rarity: String) -> void:
    if not OS.has_feature("mobile"):
        return
    match rarity:
        "legendary": Input.vibrate_handheld(70)
        "epic": Input.vibrate_handheld(52)
        "rare": Input.vibrate_handheld(40)
        _: Input.vibrate_handheld(20)
