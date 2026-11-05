extends SceneTree
## Teste de integracao real Godot 4.3, sem interface grafica.
## Exercita a cena principal e o ciclo de plantio/rega/colheita/salvamento.

var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _expect(value: bool, reason: String) -> void:
    if not value:
        failures.append(reason)
        push_error("FARMING TEST FAILED: " + reason)


func _run() -> void:
    var packed := load("res://scenes/farm_world.tscn") as PackedScene
    if packed == null:
        push_error("Cena 3D principal nao encontrada.")
        quit(1)
        return

    var world := packed.instantiate()
    root.add_child(world)
    # Os sistemas da fazenda constroem o ambiente em call_deferred.
    await process_frame
    await process_frame
    await process_frame

    var life := world.get_node_or_null("LifeSim")
    var farm := world.get_node_or_null("FarmingSystem")
    _expect(life != null, "No LifeSim existe")
    _expect(farm != null, "No FarmingSystem existe")
    if life == null or farm == null:
        quit(1)
        return
    _expect(bool(life.initialized), "LifeSim inicializado")
    _expect(bool(farm.initialized), "FarmingSystem inicializado")
    _expect(farm.plots.size() == 30, "30 canteiros")

    # O teste usa o arquivo do runner; o save do jogador nao e afetado.
    life.seeds = 10
    life.harvested = 0
    var planted_msg: String = farm.interact(0)
    _expect(bool(farm.plots[0]["planted"]), "Cenoura plantada")
    _expect(int(life.seeds) == 9, "Plantar consome uma semente")
    _expect(planted_msg.contains("plantado"), "Mensagem de plantio")

    farm.tool_index = 1  # Regar
    for stage in range(1, 4):
        farm.interact(0)
        _expect(bool(farm.plots[0]["watered"]), "Canteiro regado no dia %d" % stage)
        farm.advance_day(false)
        _expect(int(farm.plots[0]["growth"]) == stage, "Avanco da planta para fase %d" % stage)

    farm.tool_index = 2  # Colher
    var harvest_msg: String = farm.interact(0)
    _expect(harvest_msg.contains("Colheu"), "Mensagem de colheita")
    _expect(int(life.harvested) == 3, "Tres produtos no inventario")
    _expect(not bool(farm.plots[0]["planted"]), "Solo livre apos colher")

    # Testa um segundo canteiro e a persistencia no mesmo arquivo de save.
    farm.tool_index = 0
    farm.seed_type = 2  # Tomate
    farm.interact(1)
    life._save_progress()
    life.harvested = 0
    life.seeds = 0
    farm.plots[1]["planted"] = false
    life._load_progress()

    _expect(int(life.harvested) == 3, "Colheita restaurada")
    _expect(int(life.seeds) == 8, "Sementes restauradas")
    _expect(bool(farm.plots[1]["planted"]), "Plantacao restaurada")
    _expect(int(farm.plots[1]["crop"]) == 2, "Tipo de cultura restaurado")

    world.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASSOU: 30 canteiros, plantio, rega, crescimento, colheita e save/load.")
        quit(0)
    else:
        print("FALHAS NO TESTE: %s" % str(failures))
        quit(1)
