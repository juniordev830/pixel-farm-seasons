extends SceneTree
## Smoke test UI Godot: captura os estados do HUD sem captura de tela.
var errors: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _expect(condition: bool, message: String) -> void:
    if not condition:
        errors.append(message)
        push_error("COZY HUD TEST FAILED: " + message)


func _run() -> void:
    var scene := load("res://scenes/farm_world.tscn") as PackedScene
    _expect(scene != null, "Cena principal encontrada")
    if scene == null:
        quit(1)
        return
    var world := scene.instantiate()
    root.add_child(world)
    for i in range(6):
        await process_frame
    var hud := world.get_node_or_null("CozyGameHUD") as CanvasLayer
    var life := world.get_node_or_null("LifeSim") as Node3D
    _expect(hud != null, "HUD visual carregada")
    _expect(life != null and bool(life.get("initialized")), "LifeSim inicializada")
    if hud != null and life != null:
        hud._refresh_data()
        var overlay := hud.get_node_or_null("CozyOverlay")
        _expect(overlay != null, "Camada visual construida")
        if overlay != null:
            _expect(overlay.get_node_or_null("Calendar") != null, "Calendario visivel")
            _expect(overlay.get_node_or_null("Needs") != null, "Medidores de necessidades visiveis")
            _expect(overlay.get_node_or_null("Agenda") != null, "Lista de tarefas visivel")
            _expect(overlay.get_node_or_null("Inventory") != null, "Inventario compacto visivel")
            _expect(overlay.get_node_or_null("Interaction") != null, "Prompt de interacao visivel")
            _expect(overlay.get_node_or_null("Thought") != null, "Pensamento do personagem visivel")
        _expect(hud.subtitle.text.contains("Dia"), "Relogio e dia atualizados")
        life.hunger = 21.0
        life.energy = 64.0
        life.meals["almoco"] = false
        life.minutes = 660.0
        life._refresh_reminder()
        hud._refresh_data()
        _expect(int(hud.hunger_bar.value) == 21, "Fome na nova barra")
        _expect(int(hud.energy_bar.value) == 64, "Energia na nova barra")
        _expect(hud.warning_label.text.contains("11h"), "Pensamento de almoco integrado")
        life.meals["almoco"] = true
        life._refresh_reminder()
        hud._refresh_data()
        _expect(not hud.warning_label.text.contains("11h"), "Pensamento muda apos almoco")
    world.queue_free()
    await process_frame
    if errors.is_empty():
        print("PASSOU: HUD, relogio, rotina, barras, inventario, pensamentos.")
        quit(0)
    else:
        quit(1)
