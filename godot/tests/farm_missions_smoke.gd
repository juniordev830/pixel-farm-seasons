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
    world.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASSOU: campanha rural, recompensas unicas, objetivos e final do jogo.")
        quit(0)
    else:
        quit(1)
