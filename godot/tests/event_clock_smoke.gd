extends SceneTree
## Relogio hibrido: passa tempo parado + atividades + deslocamento.
## Testa rotina das refeicoes, tarefas, meia-noite e sono.

var problems: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _check(ok: bool, description: String) -> void:
    if not ok:
        problems.append(description)
        push_error("EVENT CLOCK TEST FAILED: " + description)


func _run() -> void:
    var packed := load("res://scenes/farm_world.tscn") as PackedScene
    if packed == null:
        push_error("Nao foi possivel carregar a cena da fazenda.")
        quit(1)
        return

    var world := packed.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    await process_frame

    var life := world.get_node_or_null("LifeSim")
    var farming := world.get_node_or_null("FarmingSystem")
    _check(life != null, "LifeSim presente na cena")
    _check(farming != null, "FarmingSystem presente na cena")
    if life == null or farming == null:
        quit(1)
        return

    _check(bool(life.initialized), "Sistema de vida inicializado")
    life.day = 1
    life.minutes = 390.0

    # Mesmo sem andar e sem agir, o relogio segue seu curso.
    life.farmer.set_physics_process(false)
    life._reset_travel_position()
    for i in range(10):
        await process_frame
    _check(float(life.minutes) > 390.0, "Relogio avanca quando o jogador fica parado")
    _check(float(life.minutes) < 392.0, "Tempo em repouso usa ritmo moderado")

    # O pensamento deve lembrar do almoco pelo horario.
    life.minutes = 660.0
    life.meals["almoco"] = false
    life._refresh_reminder()
    _check(life.hud_thought.text.contains("11h"), "Fazendeiro lembra do almoco as 11h")
    life.meals["almoco"] = true
    life._refresh_reminder()
    _check(not life.hud_thought.text.contains("11h"), "Lembrete desaparece apos almocar")
    life.meals["almoco"] = false

    life.minutes = 390.0
    life.advance_activity("preparar_refeicao")
    _check(is_equal_approx(float(life.minutes), 400.0), "Preparar cafe consome 10 minutos")
    life.advance_activity("cafe")
    _check(is_equal_approx(float(life.minutes), 420.0), "Cafe consome 20 minutos")
    life.advance_activity("alimentar_animais")
    _check(is_equal_approx(float(life.minutes), 445.0), "Alimentar animais consome 25 minutos")

    # Deslocamento: 80 metros a pe equivalem a 1 minuto do jogo.
    life._reset_travel_position()
    for i in range(8):
        life.farmer.global_position += Vector3(10.0, 0.0, 0.0)
        life._measure_travel()
    _check(is_equal_approx(float(life.minutes), 446.0), "Caminhada proporcional a distancia percorrida")

    # Plantacao regada evolui quando o evento leva o horario para outro dia.
    life.seeds = 10
    farming.plots[0] = {"planted": false, "growth": 0, "watered": false, "crop": 0}
    farming._render_plot(0)
    farming.tool_index = 0
    farming.interact(0)
    farming.tool_index = 1
    farming.interact(0)
    _check(bool(farming.plots[0]["watered"]), "Horta foi regada")

    life.day = 2
    life.minutes = 1430.0
    life.advance_minutes(25.0)
    _check(int(life.day) == 3, "Acontecimento atravessa a meia-noite")
    _check(is_equal_approx(float(life.minutes), 15.0), "Minutos restantes depois de virar o dia")
    _check(int(farming.plots[0]["growth"]) == 1, "Planta cresceu na virada do dia")

    life.minutes = 1230.0
    life.day = 3
    life._sleep()
    _check(int(life.day) == 4, "Dormir inicia proximo dia")
    _check(is_equal_approx(float(life.minutes), 390.0), "Acordar as 06:30")

    # Nao alterar permanentemente o progresso salvo no teste anterior.
    world.queue_free()
    await process_frame
    if problems.is_empty():
        print("PASSOU: relogio hibrido, tempo parado, horario do almoco, tarefas, caminhada, meia-noite e sono.")
        quit(0)
    else:
        print("FALHAS: %s" % str(problems))
        quit(1)
