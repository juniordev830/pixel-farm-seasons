extends SceneTree
## Verifica fisica simplificada do Fusca sem depender de input real do teclado.
const LifeSim = preload("res://scripts/life_sim.gd")
var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _check(ok: bool, why: String) -> void:
    if not ok:
        failures.append(why)
        push_error("CAR MOTION TEST FAILED: " + why)


func _run() -> void:
    var first: float = LifeSim.next_car_speed(0.0, 1.0, 100.0, 0.1)
    _check(first > 0.0 and first < 12.0, "Acelera gradualmente")
    var coast: float = LifeSim.next_car_speed(3.0, 0.0, 100.0, 0.1)
    _check(coast > 0.0 and coast < 3.0, "Soltar W desacelera sem parar instantaneamente")
    var braking: float = LifeSim.next_car_speed(3.0, -1.0, 100.0, 0.1)
    _check(braking > 0.0 and braking < coast, "Trocar para re acelera a frenagem")
    _check(is_equal_approx(LifeSim.next_car_speed(12.0, 1.0, 100.0, 1.0), 12.0), "Limite de frente")
    _check(is_equal_approx(LifeSim.next_car_speed(-5.0, -1.0, 100.0, 1.0), -5.0), "Limite de re")
    _check(LifeSim.next_car_speed(0.0, 1.0, 10.0, 2.0) < 4.0, "Desgaste reduz velocidade maxima")
    _check(LifeSim.next_car_speed(2.0, 1.0, 100.0, 0.0) == 2.0, "Delta zero nao altera velocidade")

    var packed := load("res://scenes/farm_world.tscn") as PackedScene
    _check(packed != null, "Cena da fazenda existe")
    if packed == null:
        quit(1)
        return
    var world := packed.instantiate()
    root.add_child(world)
    for i in range(8):
        await physics_frame
    var life := world.get_node_or_null("LifeSim")
    _check(life != null and bool(life.get("initialized")), "LifeSim inicializado")
    if life != null and bool(life.get("initialized")):
        life.call("_enter_car")
        _check(bool(life.get("driving")), "Entrar ativa direcao")
        _check(is_zero_approx(float(life.get("car_speed"))), "Entrar parte de velocidade zero")

        Input.action_press("move_forward")
        for i in range(12):
            await physics_frame
        Input.action_release("move_forward")
        var moving: float = float(life.get("car_speed"))
        _check(moving > 0.0 and moving < 12.0, "Aceleracao progressiva integrada a cena")
        for i in range(12):
            await physics_frame
        var released: float = float(life.get("car_speed"))
        _check(released < moving, "Fusca perde velocidade ao soltar acelerador")
        var car: CharacterBody3D = life.get("car") as CharacterBody3D
        if car != null:
            car.global_position.y += 2.0
            car.velocity = Vector3.ZERO
            var raised_height: float = car.global_position.y
            for i in range(12):
                await physics_frame
            _check(car.global_position.y < raised_height - 0.05, "Gravidade faz o carro voltar ao terreno")
        life.call("_exit_car")
        _check(not bool(life.get("driving")), "Sair termina a direcao")
        _check(is_zero_approx(float(life.get("car_speed"))), "Sair zera a velocidade")
        _check(car != null and car.velocity.is_zero_approx(), "Carro nao continua andando sem motorista")

    Input.action_release("move_forward")
    world.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASSOU: aceleracao, re, gravidade e parada segura do Fusca.")
        quit(0)
    else:
        quit(1)
