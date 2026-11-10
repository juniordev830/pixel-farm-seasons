extends SceneTree
const Missions = preload("res://scripts/farm_missions.gd")
var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _expect(ok: bool, why: String) -> void:
    if not ok:
        failures.append(why)
        push_error("FARM MISSIONS TEST FAILED: " + why)


func _run() -> void:
    var stats := {"harvested": 0, "animal_days": 0, "milk": 0, "eggs": 0, "sold": 0, "days": 0}
    var complete: Array[String] = []
    _expect(Missions.describe(stats, complete).contains("Colha"), "Primeira missao visivel")
    _expect(not Missions.completed(stats, complete), "Campanha nao inicia terminada")
    var invalid_claims: Array[String] = ["harvest", "animals", "produce", "eggs", "market", "unknown"]
    _expect(not Missions.completed(stats, invalid_claims), "Chave desconhecida nao conclui campanha")
    _expect(String(Missions.next_goal(stats, invalid_claims).get("key", "")) == "days", "Objetivo pendente continua visivel")
    var duplicate_claims: Array[String] = ["harvest", "harvest", "harvest", "harvest", "harvest", "harvest"]
    _expect(not Missions.completed(stats, duplicate_claims), "Chaves repetidas nao concluem campanha")
    var all_claims: Array[String] = ["harvest", "animals", "produce", "eggs", "market", "days"]
    _expect(Missions.completed(stats, all_claims), "Todas as chaves validas concluem campanha")
    var packed := load("res://scenes/farm_world.tscn") as PackedScene
    _expect(packed != null, "Cena 3D disponivel")
    if packed == null:
        quit(1)
        return
    var world := packed.instantiate()
    root.add_child(world)
    for i in range(5):
        await process_frame
    var life := world.get_node_or_null("LifeSim")
    _expect(life != null and bool(life.initialized), "Partida inicializa")
    if life != null and bool(life.initialized):
        life.mission_stats["harvested"] = 6
        life._review_missions()
        _expect("harvest" in life.mission_completed, "Missao de colheita premiada")
        var cash_after := int(life.coins)
        life._review_missions()
        _expect(int(life.coins) == cash_after, "Premiacao nao duplicada")
        _expect(String(life.current_mission_text()).contains("animais"), "Segunda missao liberada")
        life.mission_stats["animal_days"] = 3
        life.mission_stats["milk"] = 4
        life.mission_stats["eggs"] = 9
        life.mission_stats["sold"] = 6
        life.mission_stats["days"] = 7
        life._review_missions()
        _expect(bool(life.campaign_finished), "Campanha com final alcancavel")
        _expect(Missions.completed(life.mission_stats, life.mission_completed), "Todas missoes completas")
        var ending := world.get_node_or_null("CampaignEnding")
        _expect(ending != null, "Tela final instalada no mundo")
        if ending != null:
            _expect(bool(ending.visible), "Tela final aparece quando ganha")
            _expect(paused, "Campanha pausada ao exibir final")
            ending.continue_after_victory()
            _expect(not paused, "Modo livre retoma simulacao")
            _expect(not bool(ending.visible), "Tela final fecha sem resetar progresso")
    world.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASSOU: campanha rural, recompensas unicas, objetivos e final do jogo.")
        quit(0)
    else:
        quit(1)
