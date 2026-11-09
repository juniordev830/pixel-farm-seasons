extends SceneTree
## Testes da tela inicial e validacao de saves sem alterar o save real do jogador.
const MainMenu = preload("res://scripts/main_menu.gd")
const TEST_SAVE := "user://pixel_farm_title_test_save.json"
var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _check(ok: bool, why: String) -> void:
    if not ok:
        failures.append(why)
        push_error("TITLE SCREEN TEST FAILED: " + why)


func _run() -> void:
    _check(String(ProjectSettings.get_setting("application/run/main_scene")) == "res://scenes/main_menu.tscn", "Menu definido como entrada")
    var packed := load("res://scenes/main_menu.tscn") as PackedScene
    _check(packed != null, "Cena do menu existe")
    if packed == null:
        quit(1)
        return

    var world_menu := packed.instantiate()
    root.add_child(world_menu)
    await process_frame
    _check(world_menu.get_node_or_null("Background/Center/MainPanel") != null, "Painel inicial construido")
    _check(world_menu.continue_button != null, "Opcao continuar presente")
    _check(world_menu.new_game_confirmation != null, "Nova partida pede confirmacao")
    _check(world_menu.get_node_or_null("ConfirmNewGame") != null, "Dialogo de confirmacao existe")

    var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
    _check(file != null, "Arquivo temporario criado")
    if file != null:
        file.store_string('{"version":1,"day":8,"coins":245,"level":4,"campaign_finished":true}')
        file = null
        var valid: Dictionary = MainMenu.inspect_save(TEST_SAVE)
        _check(bool(valid.get("valid", false)), "Save valido reconhecido")
        _check(int(valid.get("day", 0)) == 8, "Dia restaurado")
        _check(int(valid.get("level", 0)) == 4, "Nivel restaurado")
        _check(not bool(valid.get("finished", true)), "Indicador antigo sozinho nao conclui campanha")
        file = FileAccess.open(TEST_SAVE, FileAccess.WRITE)
        if file != null:
            file.store_string('{"version":1,"day":8,"coins":245,"level":4,"campaign_finished":true,"mission_completed":["harvest","animals","produce","eggs","market","days"]}')
            file = null
            var completed: Dictionary = MainMenu.inspect_save(TEST_SAVE)
            _check(bool(completed.get("finished", false)), "Campanha completa exige todas as missoes")
        file = FileAccess.open(TEST_SAVE, FileAccess.WRITE)
        if file != null:
            file.store_string('{"version":1,"day":8,"coins":245,"campaign_finished":true,"mission_completed":["harvest","harvest","produce","eggs","market","unknown"]}')
            file = null
            var incomplete: Dictionary = MainMenu.inspect_save(TEST_SAVE)
            _check(not bool(incomplete.get("finished", true)), "Missoes repetidas ou desconhecidas nao completam campanha")
        var invalid_saves := [
            '{"version":1,"day":"oito","coins":245}',
            '{"version":1,"day":8,"coins":"245"}',
            '{"version":1,"day":0,"coins":245}',
            '{"version":1,"day":8,"coins":-1}',
            '{"version":1,"day":8.5,"coins":245}',
            '{"version":1,"day":8,"coins":245,"level":"alto"}',
            '{"version":2,"day":8,"coins":245}',
            '{"version":1,"day":8,"coins":245,"minutes":"tarde"}',
            '{"version":1,"day":8,"coins":245,"hunger":null}',
            '{"version":1,"day":8,"coins":245,"car_pos":[0,"longe",0]}',
            '{"version":1,"day":8,"coins":245,"mission_completed":"harvest"}',
            '{"version":1,"day":8,"coins":245,"seeds":"muitas"}',
            "{save-quebrado"
        ]
        for invalid_contents in invalid_saves:
            file = FileAccess.open(TEST_SAVE, FileAccess.WRITE)
            if file != null:
                file.store_string(invalid_contents)
                file = null
                var invalid: Dictionary = MainMenu.inspect_save(TEST_SAVE)
                _check(not bool(invalid.get("valid", true)), "Save malformado bloqueado: " + invalid_contents)
    if FileAccess.file_exists(TEST_SAVE):
        DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))

    world_menu.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASSOU: entrada no jogo, confirmacao, leitura de save e bloqueio de save corrompido.")
        quit(0)
    else:
        quit(1)
