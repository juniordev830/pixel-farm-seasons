extends SceneTree
## Testes de necessidades e progressao da cena principal.
## Executar: godot --headless --path godot --script res://tests/rural_vitals_smoke.gd
const Vitals = preload("res://scripts/rural_vitals.gd")
var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _expect(ok: bool, description: String) -> void:
    if not ok:
        failures.append(description)
        push_error("RURAL VITALS TEST FAILED: " + description)


func _run() -> void:
    _expect(is_equal_approx(Vitals.movement_multiplier(100.0, 100.0), 1.0), "Velocidade normal")
    _expect(Vitals.movement_multiplier(10.0, 100.0) < 1.0, "Fome reduz velocidade")
    _expect(Vitals.movement_multiplier(100.0, 5.0) < 1.0, "Cansaco reduz velocidade")
    _expect(Vitals.movement_multiplier(10.0, 5.0) >= 0.42, "Velocidade minima segura")

    var normal: Dictionary = Vitals.advance(50.0, 50.0, 60.0, false, false)
    var running: Dictionary = Vitals.advance(50.0, 50.0, 60.0, true, false)
    var night: Dictionary = Vitals.advance(50.0, 50.0, 60.0, false, true)
    _expect(float(normal["satiety"]) < 50.0, "Saciedade cai com tempo")
    _expect(float(running["energy"]) < float(normal["energy"]), "Corrida cansa mais")
    _expect(float(night["energy"]) < float(normal["energy"]), "Noite cansa mais")
    _expect(is_equal_approx(float(Vitals.advance(0.0, 0.0, 1000.0, true, true)["energy"]), 0.0), "Sem energia negativa")

    # Valores de save ou chamadas externas nao podem extrapolar 0..100.
    var overfilled: Dictionary = Vitals.advance(150.0, 180.0, 10.0, false, false)
    _expect(float(overfilled["satiety"]) <= 100.0, "Saciedade limitada ao maximo apos avancar")
    _expect(float(overfilled["energy"]) <= 100.0, "Energia limitada ao maximo apos avancar")
    var depleted: Dictionary = Vitals.advance(-5.0, -10.0, 10.0, true, true)
    _expect(is_equal_approx(float(depleted["satiety"]), 0.0), "Saciedade nunca negativa")
    _expect(is_equal_approx(float(depleted["energy"]), 0.0), "Energia nunca negativa")

    var packed := load("res://scenes/farm_world.tscn") as PackedScene
    _expect(packed != null, "Cena principal carregada")
    if packed == null:
        quit(1)
        return
    var world := packed.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    await process_frame

    var life := world.get_node_or_null("LifeSim")
    var farmer := world.get_node_or_null("Farmer")
    _expect(life != null and farmer != null, "Vida e personagem presentes")
    if life != null and farmer != null:
        _expect(bool(life.initialized), "Sistema de vida inicializado")
        life.hunger = 10.0
        life.energy = 8.0
        _expect(life.movement_multiplier() < 0.7, "Penalidade integrada ao LifeSim")
        life.hunger = 100.0
        life.energy = 100.0
        _expect(is_equal_approx(life.movement_multiplier(), 1.0), "Recuperacao de movimento")
        var start_level := int(life.level)
        var start_exp := int(life.experience)
        life._award_experience(200)
        _expect(int(life.level) > start_level, "Progresso concede niveis")
        _expect(int(life.experience) >= 0, "Experiencia nao fica negativa")
        _expect(start_exp >= 0, "Experiencia anterior valida")
        _expect(farmer.get_node_or_null("CameraPivot/SpringArm3D/Camera3D") != null, "Camera atras do personagem")

    world.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASSOU: fome, energia, corrida, noite, niveis e cena 3D.")
        quit(0)
    else:
        print("FALHAS: %s" % str(failures))
        quit(1)
