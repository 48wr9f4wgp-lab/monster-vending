class_name CollectionSheet
extends PanelContainer

const MONSTER_TOKEN_SCRIPT := preload("res://scripts/presentation/components/monster_token.gd")

var title_label: Label
var grid: GridContainer
var detail_label: Label
var close_button: Button
var open_y: float = 0.0
var closed_y: float = 0.0
var motion: Tween

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    z_index = 30
    open_y = position.y
    closed_y = 1296.0
    _apply_panel_style()
    _build_ui()
    visible = false

func _apply_panel_style() -> void:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.085, 0.072, 0.14, 0.985)
    style.border_color = Color(0.42, 0.30, 0.64, 1.0)
    style.set_border_width_all(2)
    style.corner_radius_top_left = 28
    style.corner_radius_top_right = 28
    style.corner_radius_bottom_left = 18
    style.corner_radius_bottom_right = 18
    style.content_margin_left = 22.0
    style.content_margin_right = 22.0
    style.content_margin_top = 18.0
    style.content_margin_bottom = 18.0
    add_theme_stylebox_override("panel", style)

func _build_ui() -> void:
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 12)
    add_child(root)

    var header := HBoxContainer.new()
    header.add_theme_constant_override("separation", 10)
    root.add_child(header)

    title_label = Label.new()
    title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title_label.add_theme_font_size_override("font_size", 30)
    title_label.text = "COLLECTION  0 / 8"
    header.add_child(title_label)

    close_button = Button.new()
    close_button.custom_minimum_size = Vector2(64, 52)
    close_button.add_theme_font_size_override("font_size", 24)
    close_button.text = "✕"
    close_button.pressed.connect(close_sheet)
    header.add_child(close_button)

    var subtitle := Label.new()
    subtitle.add_theme_color_override("font_color", Color(0.73, 0.70, 0.84, 1.0))
    subtitle.add_theme_font_size_override("font_size", 17)
    subtitle.text = "DISCOVER · GROW · KEEP THEM IN YOUR WORLD"
    root.add_child(subtitle)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    root.add_child(scroll)

    grid = GridContainer.new()
    grid.columns = 2
    grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    grid.add_theme_constant_override("h_separation", 12)
    grid.add_theme_constant_override("v_separation", 12)
    scroll.add_child(grid)

    detail_label = Label.new()
    detail_label.custom_minimum_size = Vector2(0, 44)
    detail_label.add_theme_color_override("font_color", Color(0.78, 0.74, 0.90, 1.0))
    detail_label.add_theme_font_size_override("font_size", 16)
    detail_label.text = "Every duplicate feeds visible growth."
    detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    root.add_child(detail_label)

func open_sheet() -> void:
    refresh_from_state()
    if motion != null and motion.is_valid():
        motion.kill()
    visible = true
    position.y = closed_y
    modulate.a = 0.88
    motion = create_tween()
    motion.set_parallel(true)
    motion.tween_property(self, "position:y", open_y, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    motion.tween_property(self, "modulate:a", 1.0, 0.16)

func close_sheet() -> void:
    if not visible:
        return
    if motion != null and motion.is_valid():
        motion.kill()
    motion = create_tween()
    motion.set_parallel(true)
    motion.tween_property(self, "position:y", closed_y, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
    motion.tween_property(self, "modulate:a", 0.86, 0.14)
    motion.chain().tween_callback(_finish_close)

func _finish_close() -> void:
    visible = false
    position.y = open_y
    modulate.a = 1.0

func toggle_sheet() -> void:
    if visible:
        close_sheet()
    else:
        open_sheet()

func is_open() -> bool:
    return visible

func refresh_from_state() -> void:
    if title_label == null or grid == null:
        return
    title_label.text = "COLLECTION  %d / %d" % [GameState.unique_monster_count(), DataRepository.monsters.size()]
    for child in grid.get_children():
        grid.remove_child(child)
        child.queue_free()

    for monster in DataRepository.monsters:
        grid.add_child(_build_card(monster))

func _build_card(monster: Dictionary) -> PanelContainer:
    var monster_id := String(monster.get("id", ""))
    var discovered := GameState.discovered_species.has(monster_id)
    var card := PanelContainer.new()
    card.custom_minimum_size = Vector2(298, 202)
    card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    card.add_theme_stylebox_override("panel", _card_style(discovered, String(monster.get("rarity", "common"))))

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 10)
    card.add_child(row)

    var visual_holder := CenterContainer.new()
    visual_holder.custom_minimum_size = Vector2(118, 172)
    row.add_child(visual_holder)

    if discovered:
        var token: MonsterToken = MONSTER_TOKEN_SCRIPT.new()
        token.custom_minimum_size = Vector2(108, 108)
        token.size = Vector2(108, 108)
        token.configure(monster, int(GameState.monster_star_levels.get(monster_id, 1)))
        visual_holder.add_child(token)
    else:
        var lock := Label.new()
        lock.custom_minimum_size = Vector2(108, 108)
        lock.add_theme_color_override("font_color", Color(0.42, 0.39, 0.52, 1.0))
        lock.add_theme_font_size_override("font_size", 54)
        lock.text = "?"
        lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        lock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
        visual_holder.add_child(lock)

    var info := VBoxContainer.new()
    info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info.add_theme_constant_override("separation", 5)
    row.add_child(info)

    var name_label := Label.new()
    name_label.add_theme_font_size_override("font_size", 22)
    name_label.text = String(monster.get("name", "???")) if discovered else "???"
    info.add_child(name_label)

    var rarity_label := Label.new()
    rarity_label.add_theme_color_override("font_color", _rarity_color(String(monster.get("rarity", "common"))) if discovered else Color(0.48, 0.46, 0.56, 1.0))
    rarity_label.add_theme_font_size_override("font_size", 15)
    rarity_label.text = String(monster.get("rarity", "common")).to_upper() if discovered else "UNDISCOVERED"
    info.add_child(rarity_label)

    if discovered:
        var star := int(GameState.monster_star_levels.get(monster_id, 1))
        var star_label := Label.new()
        star_label.add_theme_font_size_override("font_size", 19)
        star_label.text = "★%d" % star
        info.add_child(star_label)

        var dna_label := Label.new()
        dna_label.add_theme_color_override("font_color", Color(0.84, 0.80, 0.93, 1.0))
        dna_label.add_theme_font_size_override("font_size", 14)
        var target := _dna_target(star)
        var dna := int(GameState.monster_dna.get(monster_id, 0))
        dna_label.text = "DNA  MAX" if target <= 0 else "DNA  %d / %d" % [dna, target]
        info.add_child(dna_label)

        var dna_bar := ProgressBar.new()
        dna_bar.custom_minimum_size = Vector2(0, 18)
        dna_bar.show_percentage = false
        dna_bar.max_value = float(maxi(1, target))
        dna_bar.value = float(target if target <= 0 else mini(dna, target))
        info.add_child(dna_bar)

        var income_label := Label.new()
        income_label.add_theme_color_override("font_color", Color(0.65, 0.84, 0.72, 1.0))
        income_label.add_theme_font_size_override("font_size", 13)
        income_label.text = "+%.2f/s" % (float(monster.get("income_per_second", 0.0)) * _star_multiplier(star))
        info.add_child(income_label)
    else:
        var hint := Label.new()
        hint.add_theme_color_override("font_color", Color(0.52, 0.50, 0.60, 1.0))
        hint.add_theme_font_size_override("font_size", 14)
        hint.text = "Find it in\nthe machine."
        info.add_child(hint)

    return card

func _card_style(discovered: bool, rarity: String) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.13, 0.105, 0.20, 0.98) if discovered else Color(0.075, 0.07, 0.10, 0.96)
    style.border_color = _rarity_color(rarity) * Color(1, 1, 1, 0.70) if discovered else Color(0.24, 0.22, 0.30, 1.0)
    style.set_border_width_all(2)
    style.corner_radius_top_left = 18
    style.corner_radius_top_right = 18
    style.corner_radius_bottom_left = 18
    style.corner_radius_bottom_right = 18
    style.content_margin_left = 10.0
    style.content_margin_right = 10.0
    style.content_margin_top = 10.0
    style.content_margin_bottom = 10.0
    return style

func _rarity_color(rarity: String) -> Color:
    match rarity:
        "legendary": return Color(1.0, 0.76, 0.24, 1.0)
        "epic": return Color(0.83, 0.42, 1.0, 1.0)
        "rare": return Color(0.28, 0.68, 1.0, 1.0)
        "uncommon": return Color(0.36, 0.86, 0.57, 1.0)
        _: return Color(0.74, 0.74, 0.82, 1.0)

func _dna_target(star: int) -> int:
    match star:
        1: return 1
        2: return 3
        _: return 0

func _star_multiplier(star: int) -> float:
    match star:
        2: return 1.5
        3: return 2.2
        _: return 1.0
