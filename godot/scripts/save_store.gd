extends RefCounted
## Save staging and recovery. Never writes directly into the live save.
## The .backup file belongs to the explicit "Nova partida" action only.

static func _read_dictionary(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var decoded: Variant = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(decoded) != TYPE_DICTIONARY:
        return {}
    return decoded


static func _looks_like_save(data: Dictionary) -> bool:
    if data.is_empty():
        return false
    for field in ["version", "day", "coins"]:
        var value: Variant = data.get(field, null)
        if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
            return false
        if not is_finite(float(value)):
            return false
    return int(data["version"]) == 1 and float(data["day"]) >= 1.0 and float(data["coins"]) >= 0.0


static func write_payload(path: String, payload: Dictionary) -> bool:
    if not _looks_like_save(payload):
        push_warning("SaveStore: recusando snapshot incompleto.")
        return false

    # A crash during this write can only damage .tmp, not the active save.
    var temporary := path + ".tmp"
    var writer := FileAccess.open(temporary, FileAccess.WRITE)
    if writer == null:
        push_warning("SaveStore: arquivo temporario indisponivel.")
        return false
    writer.store_string(JSON.stringify(payload))
    writer.flush()
    writer.close()

    if not _looks_like_save(_read_dictionary(temporary)):
        push_warning("SaveStore: arquivo temporario nao passou na verificacao.")
        return false

    if FileAccess.file_exists(path):
        var current := _read_dictionary(path)
        if _looks_like_save(current):
            # Do not overwrite the player's manual New Game .backup file.
            if DirAccess.copy_absolute(
                ProjectSettings.globalize_path(path),
                ProjectSettings.globalize_path(path + ".recovery")
            ) != OK:
                push_warning("SaveStore: nao foi possivel preservar o save anterior.")
                return false

    # Godot's rename replaces an existing regular file on supported platforms.
    # If it fails, the original and/or the .recovery copy remain available.
    var error := DirAccess.rename_absolute(
        ProjectSettings.globalize_path(temporary),
        ProjectSettings.globalize_path(path)
    )
    if error != OK:
        push_warning("SaveStore: falha ao finalizar o salvamento (%d)." % error)
        return false
    return true


static func reset_for_new_game(path: String, source_for_backup: String) -> bool:
    # A new game must remove .recovery too, or it could load the old farm.
    var recovery := path + ".recovery"
    if not FileAccess.file_exists(path) and not FileAccess.file_exists(recovery):
        return true
    if not FileAccess.file_exists(source_for_backup):
        return false
    if DirAccess.copy_absolute(
        ProjectSettings.globalize_path(source_for_backup),
        ProjectSettings.globalize_path(path + ".backup")
    ) != OK:
        return false
    for old_path in [recovery, path]:
        if FileAccess.file_exists(old_path):
            if DirAccess.remove_absolute(ProjectSettings.globalize_path(old_path)) != OK:
                return false
    return true
