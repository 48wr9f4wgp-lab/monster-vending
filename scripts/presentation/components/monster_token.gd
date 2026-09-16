extends Control
class_name MonsterToken

var monster_id: String = "puff"
var display_name: String = "PUFF"
var rarity: String = "common"
var star: int = 1
var accent: Color = Color("#f4f1ff")
var reaction_busy: bool = false
var habitat_index: int = 0
var ambient_phase: float = 0.0
var ambient_bob: float = 0.0
var ambient_tick: float = 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_STOP
    pivot_offset = size * 0.5
    gui_input.connect(_on_gui_input)
    ambient_phase = float(habitat_index) * 0.73
    queue_redraw()

func _process(delta: float) -> void:
    if reaction_busy:
        return
    ambient_tick += delta
    if ambient_tick < 0.08:
        return
    var step := ambient_tick
    ambient_tick = 0.0
    ambient_phase += step * (1.15 + float(habitat_index % 3) * 0.08)
    var next_bob := sin(ambient_phase) * 2.4
    if absf(next_bob - ambient_bob) >= 0.10:
        ambient_bob = next_bob
        queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        pivot_offset = size * 0.5

func set_habitat_index(value: int) -> void:
    habitat_index = maxi(0, value)
    ambient_phase = float(habitat_index) * 0.73
    queue_redraw()

func configure(definition: Dictionary, star_level: int = 1) -> void:
    monster_id = String(definition.get("id", "puff"))
    display_name = String(definition.get("name", monster_id.to_upper()))
    rarity = String(definition.get("rarity", "common"))
    star = clampi(star_level, 1, 3)
    accent = _color_for(monster_id)
    queue_redraw()

func set_star(value: int) -> void:
    star = clampi(value, 1, 3)
    queue_redraw()

func play_spawn() -> void:
    scale = Vector2(0.15, 0.15)
    modulate.a = 0.0
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "scale", Vector2(1.14, 0.88), 0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "modulate:a", 1.0, 0.10)
    await tween.finished
    var settle := create_tween()
    settle.tween_property(self, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    await settle.finished

func play_reaction() -> void:
    if reaction_busy:
        return
    reaction_busy = true
    match monster_id:
        "puff": await _reaction_inflate()
        "bloop": await _reaction_squash()
        "shroomy": await _reaction_sleep()
        "pricky": await _reaction_angry()
        "peeko": await _reaction_peek()
        "gobble": await _reaction_gobble()
        "sparky": await _reaction_spark()
        "mimic": await _reaction_mimic()
        _: await _reaction_squash()
    reaction_busy = false

func _on_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        play_reaction()
    elif event is InputEventScreenTouch and event.pressed:
        play_reaction()

func _reaction_inflate() -> void:
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.16).set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_ELASTIC)
    await tween.finished

func _reaction_squash() -> void:
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2(1.25, 0.72), 0.10)
    tween.tween_property(self, "scale", Vector2(0.88, 1.18), 0.12)
    tween.tween_property(self, "scale", Vector2.ONE, 0.16).set_trans(Tween.TRANS_BACK)
    await tween.finished

func _reaction_sleep() -> void:
    var tween := create_tween()
    tween.tween_property(self, "rotation", deg_to_rad(8), 0.15)
    tween.tween_property(self, "position:y", position.y + 8.0, 0.15)
    await get_tree().create_timer(0.35).timeout
    var wake := create_tween()
    wake.set_parallel(true)
    wake.tween_property(self, "rotation", 0.0, 0.18)
    wake.tween_property(self, "position:y", position.y - 8.0, 0.18)
    await wake.finished

func _reaction_angry() -> void:
    var tween := create_tween()
    tween.tween_property(self, "rotation", deg_to_rad(-8), 0.06)
    tween.tween_property(self, "rotation", deg_to_rad(8), 0.06)
    tween.tween_property(self, "rotation", deg_to_rad(-6), 0.06)
    tween.tween_property(self, "rotation", 0.0, 0.08)
    await tween.finished

func _reaction_peek() -> void:
    var tween := create_tween()
    tween.tween_property(self, "position:x", position.x + 12.0, 0.12)
    tween.tween_property(self, "position:x", position.x - 12.0, 0.18)
    tween.tween_property(self, "position:x", position.x, 0.12)
    await tween.finished

func _reaction_gobble() -> void:
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2(1.18, 0.85), 0.09)
    tween.tween_property(self, "scale", Vector2(0.92, 1.18), 0.09)
    tween.tween_property(self, "scale", Vector2.ONE, 0.12)
    await tween.finished

func _reaction_spark() -> void:
    modulate = Color("#dffcff")
    var tween := create_tween()
    tween.tween_property(self, "rotation", deg_to_rad(-12), 0.05)
    tween.tween_property(self, "rotation", deg_to_rad(12), 0.05)
    tween.tween_property(self, "rotation", 0.0, 0.08)
    await tween.finished
    modulate = Color.WHITE

func _reaction_mimic() -> void:
    var tween := create_tween()
    tween.tween_property(self, "position:y", position.y - 16.0, 0.16).set_trans(Tween.TRANS_BACK)
    tween.tween_property(self, "rotation", deg_to_rad(12), 0.10)
    tween.tween_property(self, "rotation", deg_to_rad(-12), 0.10)
    tween.tween_property(self, "rotation", 0.0, 0.08)
    tween.tween_property(self, "position:y", position.y, 0.16)
    await tween.finished

func _draw() -> void:
    var c := size * 0.5 + Vector2(0, ambient_bob)
    var r := minf(size.x, size.y) * 0.28 * (1.0 + float(star - 1) * 0.08)
    var outline := Color("#2a1d3a")

    draw_ellipse_shadow(Vector2(c.x, size.y * 0.78 + ambient_bob), r * 0.76, r * 0.22)

    match monster_id:
        "bloop":
            draw_circle(c + Vector2(0, r * 0.16), r, accent)
            draw_circle(c + Vector2(-r * 0.55, r * 0.42), r * 0.46, accent)
            draw_circle(c + Vector2(r * 0.55, r * 0.42), r * 0.46, accent)
        "shroomy":
            draw_style_box(_box(accent.lightened(0.22), r * 0.35), Rect2(c.x - r * 0.42, c.y - r * 0.05, r * 0.84, r * 1.05))
            draw_colored_polygon(PackedVector2Array([Vector2(c.x - r, c.y - r * 0.05), Vector2(c.x, c.y - r * 0.95), Vector2(c.x + r, c.y - r * 0.05)]), accent)
        "pricky":
            draw_style_box(_box(accent, r * 0.38), Rect2(c.x - r * 0.45, c.y - r, r * 0.9, r * 1.85))
            draw_style_box(_box(accent, r * 0.25), Rect2(c.x - r * 0.9, c.y - r * 0.2, r * 0.55, r * 0.45))
            draw_style_box(_box(accent, r * 0.25), Rect2(c.x + r * 0.35, c.y + r * 0.05, r * 0.55, r * 0.45))
        "peeko":
            draw_circle(c, r, accent)
            draw_circle(c, r * 0.58, Color("#f8fbff"))
            draw_circle(c, r * 0.26, Color("#252035"))
        "gobble":
            draw_circle(c, r, accent)
            draw_circle(c + Vector2(0, r * 0.28), r * 0.56, Color("#3b1735"))
            draw_arc(c + Vector2(0, r * 0.28), r * 0.56, 0, TAU, 32, outline, 3.0)
        "sparky":
            draw_circle(c, r * 0.82, accent)
            draw_colored_polygon(PackedVector2Array([Vector2(c.x - r * 1.2, c.y), Vector2(c.x - r * 0.55, c.y - r * 0.32), Vector2(c.x - r * 0.64, c.y + r * 0.38)]), Color("#ffd166"))
            draw_colored_polygon(PackedVector2Array([Vector2(c.x + r * 1.2, c.y), Vector2(c.x + r * 0.55, c.y - r * 0.32), Vector2(c.x + r * 0.64, c.y + r * 0.38)]), Color("#ffd166"))
        "mimic":
            draw_circle(c, r, accent)
            draw_arc(c, r, 0, TAU, 32, outline, 4.0)
            draw_line(c + Vector2(-r * 0.9, 0), c + Vector2(r * 0.9, 0), Color("#f8f4ff"), 3.0)
            draw_line(c + Vector2(-r * 0.45, r * 0.85), c + Vector2(-r * 0.65, r * 1.18), outline, 5.0)
            draw_line(c + Vector2(r * 0.45, r * 0.85), c + Vector2(r * 0.65, r * 1.18), outline, 5.0)
        _:
            draw_circle(c, r, accent)
            for i in range(10):
                var angle := TAU * float(i) / 10.0
                draw_circle(c + Vector2(cos(angle), sin(angle)) * r * 0.88, r * 0.22, accent.lightened(0.08))

    if monster_id != "peeko":
        var eye_y := c.y - r * 0.12
        draw_circle(Vector2(c.x - r * 0.28, eye_y), r * 0.14, Color("#f8fbff"))
        draw_circle(Vector2(c.x + r * 0.28, eye_y), r * 0.14, Color("#f8fbff"))
        draw_circle(Vector2(c.x - r * 0.28, eye_y), r * 0.07, Color("#252035"))
        draw_circle(Vector2(c.x + r * 0.28, eye_y), r * 0.07, Color("#252035"))

    if star >= 2:
        draw_arc(c, r * 1.18, 0.15, PI * 1.2, 20, accent.lightened(0.35), 3.0)
    if star >= 3:
        for i in range(3):
            var a := -0.5 + i * 0.5
            draw_circle(c + Vector2(cos(a), sin(a)) * r * 1.25, r * 0.10, Color("#fff09a"))

func draw_ellipse_shadow(center: Vector2, radius_x: float, radius_y: float) -> void:
    var points := PackedVector2Array()
    var segments := 24
    for i in range(segments):
        var angle := TAU * float(i) / float(segments)
        points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
    draw_colored_polygon(points, Color(0.03, 0.02, 0.06, 0.26))

func _color_for(id: String) -> Color:
    match id:
        "puff": return Color("#f3e9ff")
        "bloop": return Color("#68d9ff")
        "shroomy": return Color("#7bd89b")
        "pricky": return Color("#76cc69")
        "peeko": return Color("#ff8a6f")
        "gobble": return Color("#ff6d78")
        "sparky": return Color("#9d80ff")
        "mimic": return Color("#ffd166")
        _: return Color("#f4f1ff")

func _box(color: Color, radius: float) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = color
    box.corner_radius_top_left = int(radius)
    box.corner_radius_top_right = int(radius)
    box.corner_radius_bottom_left = int(radius)
    box.corner_radius_bottom_right = int(radius)
    return box
