extends Node

const EVENT_RULES := {
    "session_start": {"pii": false, "purpose": "session baseline"},
    "session_end": {"pii": false, "purpose": "session duration and core-loop summary"},
    "first_vend": {"pii": false, "purpose": "FTUE time-to-first-action"},
    "vend_started": {"pii": false, "purpose": "core-loop funnel"},
    "monster_revealed": {"pii": false, "purpose": "new/duplicate and rarity balance"},
    "monster_growth": {"pii": false, "purpose": "duplicate-value funnel"},
    "machine_upgrade": {"pii": false, "purpose": "progression funnel"},
    "dial_used": {"pii": false, "purpose": "agency usage"},
    "habitat_expand": {"pii": false, "purpose": "world-growth funnel"},
    "economy_checkpoint": {"pii": false, "purpose": "runtime pacing and idle-time validation"},
    "offline_income_applied": {"pii": false, "purpose": "return-economy validation"},
    "save_game": {"pii": false, "purpose": "persistence verification"},
    "load_game": {"pii": false, "purpose": "persistence verification"}
}

var session_start_msec: int = 0

func _ready() -> void:
    session_start_msec = Time.get_ticks_msec()

func elapsed_ms() -> int:
    return maxi(0, Time.get_ticks_msec() - session_start_msec)

func track(event_name: String, properties: Dictionary = {}) -> void:
    if not EVENT_RULES.has(event_name):
        push_warning("MONSTER VENDING analytics event not in dictionary: %s" % event_name)
    var enriched := properties.duplicate(true)
    if not enriched.has("elapsed_ms"):
        enriched["elapsed_ms"] = elapsed_ms()
    print("[analytics] ", event_name, " ", enriched)
