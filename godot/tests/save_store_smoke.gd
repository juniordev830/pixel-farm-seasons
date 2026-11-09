extends SceneTree
## Testes isolados: nao toca no save real do jogador.
const SaveStore = preload("res://scripts/save_store.gd")
const MainMenu = preload("res://scripts/main_menu.gd")
const TEST_SAVE := "user://pixel_farm_save_store_smoke.json"
var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _check(condition: bool, message: String) -> void:
    if not condition:
        failures.append(message)
        push_error("SAVE STORE TEST FAILED: " + message)


func _cleanup() -> void:
    for suffix in ["", ".tmp", ".recovery", ".backup"]:
        var path := TEST_SAVE + suffix
        if FileAccess.file_exists(path):
            DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _run() -> void:
    _cleanup()
    var original := {"version": 1, "day": 3, "coins": 45, "mission_completed": ["harvest"]}
    var updated := {"version": 1, "day": 5, "coins": 100, "mission_completed": ["harvest", "animals"]}

    _check(SaveStore.write_payload(TEST_SAVE, original), "Primeiro save gravado")
    var first: Dictionary = MainMenu.inspect_save(TEST_SAVE)
    _check(bool(first.get("valid", false)) and int(first.get("day", 0)) == 3, "Primeiro save legivel")

    # Invalid payloads must never overwrite a healthy active snapshot.
    _check(not SaveStore.write_payload(TEST_SAVE, {"version": 1, "day": 0, "coins": 1}), "Snapshot invalido rejeitado")
    _check(int(MainMenu.inspect_save(TEST_SAVE).get("day", 0)) == 3, "Save preservado em gravacao recusada")

    _check(SaveStore.write_payload(TEST_SAVE, updated), "Segundo save gravado")
    var previous: Dictionary = MainMenu.inspect_save(TEST_SAVE + ".recovery")
    _check(bool(previous.get("valid", false)), "Copia de recuperacao valida")
    _check(int(previous.get("day", 0)) == 3, "Recuperacao preserva progresso anterior")
    _check(int(MainMenu.inspect_save(TEST_SAVE).get("day", 0)) == 5, "Save novo e principal")

    # Simula interrupcao: primary is corrupted and .tmp is unfinished.
    var corrupt := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
    _check(corrupt != null, "Simulacao de corrupcao")
    if corrupt != null:
        corrupt.store_string("{truncado")
        corrupt.close()
    var pending := FileAccess.open(TEST_SAVE + ".tmp", FileAccess.WRITE)
    if pending != null:
        pending.store_string("{incompleto")
        pending.close()
    var fallback: Dictionary = MainMenu.inspect_save(TEST_SAVE)
    _check(bool(fallback.get("valid", false)), "Recovery habilita Continuar")
    _check(bool(fallback.get("recovered", false)), "Menu identifica recuperacao")
    _check(String(fallback.get("source", "")) == TEST_SAVE + ".recovery", "Caminho recuperado correto")
    _check(int(fallback.get("day", 0)) == 3, "Recuperou o ultimo snapshot seguro")

    _check(SaveStore.reset_for_new_game(TEST_SAVE, String(fallback.get("source", ""))), "Nova partida gera backup")
    _check(not FileAccess.file_exists(TEST_SAVE), "Nova partida limpa save principal")
    _check(not FileAccess.file_exists(TEST_SAVE + ".recovery"), "Nova partida nao reutiliza recuperacao antiga")
    _check(not bool(MainMenu.inspect_save(TEST_SAVE).get("valid", false)), "Partida anterior nao volta sozinha")
    _check(int(MainMenu.inspect_save(TEST_SAVE + ".backup").get("day", 0)) == 3, "Backup manual contem a partida recuperada")

    _check(SaveStore.write_payload(TEST_SAVE, {"version": 1, "day": 1, "coins": 20}), "Nova fazenda salva normalmente")
    var new_game: Dictionary = MainMenu.inspect_save(TEST_SAVE)
    _check(int(new_game.get("day", 0)) == 1 and not bool(new_game.get("recovered", false)), "Nova partida independente")

    _cleanup()
    if failures.is_empty():
        print("PASSOU: escrita temporaria, snapshot anterior, recuperacao e nova partida.")
        quit(0)
    else:
        quit(1)
