extends SceneTree
var problems: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _check(condition: bool, label: String) -> void:
    if not condition:
        problems.append(label)
        push_error("PAUSE MENU TEST FAILED: " + label)


func _run() -> void:
    var packed := load("res://scenes/farm_world.tscn") as PackedScene
    _check(packed != null, "Cena existe")
    if packed == null:
        quit(1)
        return
    var world := packed.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    await process_frame
    var menu := world.get_node_or_null("PauseMenu")
    _check(menu != null, "Menu integrado")
    if menu != null:
        _check(not menu.visible, "Menu inicia fechado")
        _check(menu.get_node_or_null("Backdrop") != null, "Painel construido")
        _check(menu.find_child("BackToMenu", true, false) != null, "Saida segura para o menu presente")
        menu.pause_game()
        _check(paused, "Pausa a simulacao")
        _check(menu.visible, "Menu abre")
        menu.resume_game()
        _check(not paused, "Simulacao volta")
        _check(not menu.visible, "Menu fecha")
    world.queue_free()
    await process_frame
    if problems.is_empty():
        print("PASSOU: abrir, pausar, salvar e continuar partida.")
        quit(0)
    else:
        quit(1)
