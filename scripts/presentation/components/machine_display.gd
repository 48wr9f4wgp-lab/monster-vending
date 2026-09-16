extends Control
class_name MachineDisplay

var machine_level: int = 1
var energy: float = 0.0
var jam: float = 0.0
var _base_rotation: float = 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    pivot_offset = size * 0.5
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        pivot_offset = size * 0.5

func set_machine_level(value: int) -> void:
    machine_level = maxi(1, value)
    queue_redraw()

func set_energy(value: float) -> void:
    energy = clampf(value, 0.0, 1.0)
    queue_redraw()

func set_jam(value: float) -> void:
    jam = clampf(value, 0.0, 1.0)
    queue_redraw()

func play_press_reaction() -> void:
    var tween := create_tween()
    tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "scale", Vector2(0.97, 1.03), 0.07)
    tween.tween_property(self, "scale", Vector2.ONE, 0.10)

func play_upgrade(old_level: int, new_level: int) -> void:
    set_machine_level(new_level)
    energy = 1.0
    queue_redraw()
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_method(set_energy, 1.0, 0.0, 0.6)
    await tween.finished
    var settle := create_tween()
    settle.tween_property(self, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func play_vend_motion() -> void:
    play_press_reaction()
    set_energy(0.35)
    await get_tree().create_timer(0.12).timeout

    var shake := create_tween()
    shake.tween_property(self, "rotation", deg_to_rad(-1.8), 0.08)
    shake.tween_property(self, "rotation", deg_to_rad(1.8), 0.08)
    shake.tween_property(self, "rotation", deg_to_rad(-1.2), 0.07)
    shake.tween_property(self, "rotation", deg_to_rad(1.2), 0.07)
    shake.tween_property(self, "rotation", _base_rotation, 0.07)
    shake.parallel().tween_method(set_energy, 0.35, 0.85, 0.37)
    await shake.finished

    set_jam(1.0)
    await get_tree().create_timer(0.13).timeout
    set_jam(0.0)

    var kick := create_tween()
    kick.tween_property(self, "position:y", position.y + 8.0, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    kick.tween_property(self, "position:y", position.y - 3.0, 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    kick.tween_property(self, "position:y", position.y, 0.08)
    kick.parallel().tween_method(set_energy, 0.85, 0.2, 0.23)
    await kick.finished

func _draw() -> void:
    var w := size.x
    var h := size.y
    var center := Vector2(w * 0.5, h * 0.5)

    var body := Rect2(w * 0.14, h * 0.08, w * 0.72, h * 0.82)
    var shadow := Rect2(body.position + Vector2(0, h * 0.025), body.size)
    draw_style_box(_box(Color("#25123d"), 26.0), shadow)

    var base_color := Color("#6d35a9")
    if machine_level >= 2:
        base_color = Color("#7b3fc0")
    if machine_level >= 3:
        base_color = Color("#874bd1")
    base_color = base_color.lerp(Color("#a75dff"), energy * 0.32)
    draw_style_box(_box(base_color, 26.0), body)

    var horn_color := Color("#f3c25d")
    draw_colored_polygon(PackedVector2Array([
        Vector2(w * 0.23, h * 0.13), Vector2(w * 0.18, h * 0.00), Vector2(w * 0.30, h * 0.10)
    ]), horn_color)
    draw_colored_polygon(PackedVector2Array([
        Vector2(w * 0.77, h * 0.13), Vector2(w * 0.82, h * 0.00), Vector2(w * 0.70, h * 0.10)
    ]), horn_color)

    var eye_y := h * 0.22
    for eye_x in [w * 0.36, w * 0.64]:
        draw_circle(Vector2(eye_x, eye_y), w * 0.085, Color("#f6f2ff"))
        draw_circle(Vector2(eye_x, eye_y + jam * 3.0), w * 0.042, Color("#17111f"))
        draw_circle(Vector2(eye_x - w * 0.014, eye_y - w * 0.014), w * 0.012, Color.WHITE)

    var chamber := Rect2(w * 0.24, h * 0.38, w * 0.52, h * 0.33)
    draw_style_box(_box(Color("#251d3c"), 22.0), chamber)
    var glass := chamber.grow(-8.0)
    draw_style_box(_box(Color(0.21, 0.15, 0.36, 0.82).lerp(Color(0.42, 0.82, 1.0, 0.78), energy), 18.0), glass)

    var orb_colors := [Color("#4cc9f0"), Color("#ff5aa5"), Color("#62e6a3"), Color("#ffd166")]
    for i in range(4):
        var px := glass.position.x + glass.size.x * (0.22 + float(i % 2) * 0.56)
        var py := glass.position.y + glass.size.y * (0.28 + float(i / 2) * 0.48)
        draw_circle(Vector2(px, py), w * 0.045, orb_colors[i].lerp(Color.WHITE, energy * 0.2))
        draw_circle(Vector2(px - 4, py - 5), w * 0.012, Color(1, 1, 1, 0.72))

    for i in range(5):
        var tx := w * 0.34 + float(i) * w * 0.08
        draw_colored_polygon(PackedVector2Array([
            Vector2(tx, h * 0.71), Vector2(tx + w * 0.035, h * 0.76), Vector2(tx + w * 0.07, h * 0.71)
        ]), Color("#fff1c8"))

    if machine_level >= 2:
        var dial_center := Vector2(w * 0.20, h * 0.58)
        draw_circle(dial_center, w * 0.055, Color("#f3c25d"))
        draw_line(dial_center, dial_center + Vector2(0, -w * 0.04), Color("#442860"), 6.0)
        draw_circle(Vector2(w * 0.80, h * 0.58), w * 0.025 + energy * 4.0, Color("#72f1ff"))
    if machine_level >= 3:
        var topper := Rect2(w * 0.31, h * 0.02, w * 0.38, h * 0.08)
        draw_style_box(_box(Color("#4c266f"), 12.0), topper)
        for i in range(5):
            draw_circle(Vector2(topper.position.x + 18.0 + i * 24.0, topper.get_center().y), 5.0, Color("#7ff4ff"))

    draw_style_box(_box(Color("#322047"), 14.0), Rect2(w * 0.19, h * 0.86, w * 0.62, h * 0.08))

func _box(color: Color, radius: float) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = color
    box.corner_radius_top_left = int(radius)
    box.corner_radius_top_right = int(radius)
    box.corner_radius_bottom_left = int(radius)
    box.corner_radius_bottom_right = int(radius)
    return box
