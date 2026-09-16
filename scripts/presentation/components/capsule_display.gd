extends Control
class_name CapsuleDisplay

var accent: Color = Color("#62e6a3")
var glow: float = 0.0
var opened: float = 0.0

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    pivot_offset = size * 0.5
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        pivot_offset = size * 0.5

func set_rarity(rarity: String) -> void:
    match rarity:
        "legendary": accent = Color("#ffd166")
        "epic": accent = Color("#d56dff")
        "rare": accent = Color("#48c8ff")
        "uncommon": accent = Color("#72e48d")
        _: accent = Color("#8dd6ff")
    queue_redraw()

func set_glow(value: float) -> void:
    glow = clampf(value, 0.0, 1.0)
    queue_redraw()

func set_opened(value: float) -> void:
    opened = clampf(value, 0.0, 1.0)
    queue_redraw()

func play_drop(start_position: Vector2, end_position: Vector2) -> void:
    position = start_position
    rotation = -0.18
    scale = Vector2(0.72, 0.72)
    modulate.a = 1.0
    set_opened(0.0)
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(self, "position", end_position, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "rotation", 0.08, 0.32).set_trans(Tween.TRANS_QUAD)
    tween.tween_property(self, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    await tween.finished

func play_shake() -> void:
    var tween := create_tween()
    tween.tween_property(self, "rotation", -0.12, 0.06)
    tween.tween_property(self, "rotation", 0.12, 0.06)
    tween.tween_property(self, "rotation", -0.08, 0.05)
    tween.tween_property(self, "rotation", 0.08, 0.05)
    tween.tween_property(self, "rotation", 0.0, 0.05)
    tween.parallel().tween_method(set_glow, 0.0, 1.0, 0.27)
    await tween.finished

func play_pop() -> void:
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_method(set_opened, 0.0, 1.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "scale", Vector2(1.18, 0.88), 0.08)
    await tween.finished
    var finish := create_tween()
    finish.tween_property(self, "modulate:a", 0.0, 0.10)
    await finish.finished

func _draw() -> void:
    var c := size * 0.5
    var radius := minf(size.x, size.y) * 0.33
    if glow > 0.0:
        draw_circle(c, radius * (1.35 + glow * 0.2), Color(accent.r, accent.g, accent.b, 0.10 + glow * 0.14))
        draw_circle(c, radius * (1.12 + glow * 0.08), Color(accent.r, accent.g, accent.b, 0.15 + glow * 0.18))

    var split := opened * radius * 0.55
    draw_circle(c + Vector2(0, -split), radius, Color(accent, 0.88))
    draw_circle(c + Vector2(0, split), radius * 0.96, Color(accent.darkened(0.22), 0.94))
    draw_circle(c + Vector2(-radius * 0.28, -radius * 0.30 - split), radius * 0.18, Color(1, 1, 1, 0.58))
    draw_arc(c, radius, 0.0, TAU, 48, Color("#f8f4ff"), 4.0)
