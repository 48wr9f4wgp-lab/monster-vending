extends Node

const SAVE_PATH := "user://monster_vending_save_v2.json"
const BACKUP_PATH := "user://monster_vending_save_v2.backup.json"
const SCHEMA_VERSION := 2

func save_game() -> bool:
    var now := Time.get_datetime_string_from_system(true)
    var payload := _build_payload()
    var envelope := {
        "schema_version": SCHEMA_VERSION,
        "created_at": now,
        "updated_at": now,
        "payload": payload,
        "checksum": _checksum(payload)
    }

    if FileAccess.file_exists(SAVE_PATH):
        var previous := FileAccess.get_file_as_string(SAVE_PATH)
        var backup := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
        if backup != null:
            backup.store_string(previous)

    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        push_error("MONSTER VENDING: save open failed")
        return false
    file.store_string(JSON.stringify(envelope))

    var verified := _read_and_validate(SAVE_PATH)
    if verified.is_empty():
        push_error("MONSTER VENDING: save read-back verification failed")
        return false

    AnalyticsService.track("save_game", {"schema_version": SCHEMA_VERSION})
    return true

func load_game() -> bool:
    var envelope := _read_and_validate(SAVE_PATH)
    if envelope.is_empty():
        envelope = _read_and_validate(BACKUP_PATH)
    if envelope.is_empty():
        return false

    var payload: Dictionary = envelope.get("payload", {})
    GameState.coins = max(0.0, float(payload.get("coins", 10.0)))
    GameState.vend_count = max(0, int(payload.get("vend_count", 0)))
    GameState.machine_level = clampi(int(payload.get("machine_level", 1)), 1, 5)
    GameState.machine_xp = max(0, int(payload.get("machine_xp", 0)))
    GameState.reputation = max(0, int(payload.get("reputation", 0)))
    GameState.habitat_capacity_value = clampi(int(payload.get("habitat_capacity", 4)), 4, 8)
    GameState.selected_dial = String(payload.get("selected_dial", "cute"))
    GameState.selected_monster_id = String(payload.get("selected_monster_id", ""))
    GameState.discovered_species = payload.get("discovered_species", {})
    GameState.monster_star_levels = payload.get("monster_star_levels", {})
    GameState.monster_dna = payload.get("monster_dna", {})
    GameState.discovery_duplicates = max(0, int(payload.get("discovery_duplicates", 0)))

    GameState.last_offline_reward = 0.0
    var saved_unix := int(payload.get("last_save_unix", 0))
    var now_unix := int(Time.get_unix_time_from_system())
    if saved_unix > 0 and now_unix > saved_unix:
        GameState.apply_offline_income(float(now_unix - saved_unix))

    GameState.state_changed.emit()
    AnalyticsService.track("load_game", {"schema_version": SCHEMA_VERSION})
    return true

func _build_payload() -> Dictionary:
    return {
        "coins": GameState.coins,
        "vend_count": GameState.vend_count,
        "machine_level": GameState.machine_level,
        "machine_xp": GameState.machine_xp,
        "reputation": GameState.reputation,
        "habitat_capacity": GameState.habitat_capacity_value,
        "selected_dial": GameState.selected_dial,
        "selected_monster_id": GameState.selected_monster_id,
        "discovered_species": GameState.discovered_species,
        "monster_star_levels": GameState.monster_star_levels,
        "monster_dna": GameState.monster_dna,
        "discovery_duplicates": GameState.discovery_duplicates,
        "last_save_unix": int(Time.get_unix_time_from_system())
    }

func _checksum(payload: Dictionary) -> String:
    return (JSON.stringify(payload).sha256_text())

func _read_and_validate(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var parsed := JSON.parse_string(file.get_as_text())
    if not (parsed is Dictionary):
        return {}
    if int(parsed.get("schema_version", -1)) != SCHEMA_VERSION:
        return {}
    var payload := parsed.get("payload", {})
    if not (payload is Dictionary):
        return {}
    if String(parsed.get("checksum", "")) != _checksum(payload):
        return {}
    return parsed
