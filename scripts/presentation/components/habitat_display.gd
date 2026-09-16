extends Control
class_name HabitatDisplay

var expanded: bool = false
var decoration_unlocked: bool = false
var population: int = 0
var income_per_second: float = 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_PASS
    pivot_offset = size * 0.5
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        pivot_offset = size * 0.5

func play_expand() -> void:
    scale = Vector2(0.96, 0.96)
    modulate = Color(1.08, 1.04, 1.12, 1.0)
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "scale", Vector2(1.03, 1.03), 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "modulate", Color.WHITE, 0.28)
    await tween.finished
    var settle := create_tween()
    settle.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    await settle.finished

func set_state(capacity: int, reputation: int, monster_count: int, income: float) -> void:
    expanded = capacity >= 8
    decoration_unlocked = reputation >= 30
    population = maxi(0, monster_count)
    income_per_second = maxf(0.0, income)
    queue_redraw()

func _draw() -> void:
    var w := size.x
    var h := size.y
    if w <= 1.0 or h <= 1.0:
        return

    var back := StyleBoxFlat.new()
    back.bg_color = Color("#28233d")
    back.corner_radius_top_left = 26
    back.corner_radius_top_right = 26
    back.corner_radius_bottom_left = 26
    back.corner_radius_bottom_right = 26
    draw_style_box(back, Rect2(4, 4, w - 8, h - 8))

    draw_rect(Rect2(18, h * 0.66, w - 36, h * 0.22), Color("#403455"), true)
    draw_rect(Rect2(34, h * 0.42, w - 68, 9), Color("#6b567f"), true)
    if expanded:
        draw_rect(Rect2(22, h * 0.16, w - 44, 9), Color("#735e8b"), true)

    _draw_lamp(Vector2(48, 42), Color("#ffd79a"))
    _draw_lamp(Vector2(w - 48, 42), Color("#9ee9ff") if expanded else Color("#d4bcff"))

    if decoration_unlocked:
        _draw_plant(Vector2(54, h - 42))
        _draw_food_bowl(Vector2(w - 58, h - 30))

    var slots := 8 if expanded else 4
    for i in range(slots):
        var pos := _slot_center(i, slots, w, h)
        draw_circle(pos + Vector2(0, 38), 31, Color(0.11, 0.09, 0.18, 0.34))

func _slot_center(index: int, slots: int, w: float, h: float) -> Vector2:
    var cols := 4
    var rows := 2 if slots > 4 else 1
    var row := index / cols
    var col := index % cols
    var usable_top := 20.0 if rows == 2 else h * 0.28
    var usable_height := h - usable_top - 28.0
    var cell_w := w / float(cols)
    var cell_h := usable_height / float(rows)
    return Vector2(cell_w * (float(col) + 0.5), usable_top + cell_h * (float(row) + 0.5))

func _draw_lamp(pos: Vector2, color: Color) -> void:
    draw_circle(pos, 16, Color(color.r, color.g, color.b, 0.15))
    draw_circle(pos, 8, Color(color.r, color.g, color.b, 0.85))
    draw_line(pos + Vector2(0, -8), pos + Vector2(0, -28), Color("#706681"), 4.0)

func _draw_plant(pos: Vector2) -> void:
    draw_rect(Rect2(pos.x - 17, pos.y - 10, 34, 22), Color("#b7795c"), true)
    draw_circle(pos + Vector2(-10, -24), 14, Color("#76c887"))
    draw_circle(pos + Vector2(8, -31), 17, Color("#8bdd98"))
    draw_circle(pos + Vector2(16, -18), 12, Color("#65b979"))

func _draw_food_bowl(pos: Vector2) -> void:
    draw_colored_polygon(PackedVector2Array([
        pos + Vector2(-22, -7),
        pos + Vector2(22, -7),
        pos + Vector2(15, 10),
        pos + Vector2(-15, 10)
    ]), Color("#ff9c78"))
    draw_circle(pos + Vector2(-7, -8), 4, Color("#ffd166"))
    draw_circle(pos + Vector2(5, -10), 4, Color("#ffd166"))
