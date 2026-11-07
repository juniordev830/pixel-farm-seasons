extends SceneTree
## Smoke de geometria premium: checa estrada orgânica e câmera.
var issues: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _expect(condition: bool, why: String) -> void:
    if not condition:
        issues.append(why)
        push_error("PREMIUM VISUAL TEST FAILED: " + why)


func _run() -> void:
    var scene := load("res://scenes/farm_world.tscn") as PackedScene
    _expect(scene != null, "Cena 3D carregavel")
    if scene == null:
        quit(1)
        return
    var world := scene.instantiate()
    root.add_child(world)
    for i in range(12):
        await process_frame
    var premium := world.get_node_or_null("PremiumArtPass") as Node3D
    _expect(premium != null, "Novo art pass conectado")
    if premium != null:
        _expect(bool(premium.road_ready), "Malha do caminho gerada")
        var organic := premium.get_node_or_null("Estrada organica da fazenda") as MeshInstance3D
        _expect(organic != null and organic.mesh != null, "Estrada natural visivel")
        if organic != null and organic.mesh != null:
            _expect(organic.mesh.get_surface_count() > 0, "Estrada tem superficies")
        for title in ["Estrada da fazenda", "Caminho ate a varanda"]:
            var legacy := world.get_node_or_null(title) as MeshInstance3D
            _expect(legacy != null and not legacy.visible, "Caminho retangular oculto: " + title)
    var arm := world.get_node_or_null("Farmer/CameraPivot/SpringArm3D") as SpringArm3D
    var camera := world.get_node_or_null("Farmer/CameraPivot/SpringArm3D/Camera3D") as Camera3D
    _expect(arm != null and arm.spring_length >= 4.0 and arm.spring_length < 5.0,
        "Camera mais proxima sem entrar na primeira pessoa")
    _expect(camera != null and camera.fov <= 60.0, "FOV cinematografico")
    var life := world.get_node_or_null("LifeSim")
    _expect(life != null and bool(life.initialized), "Gameplay continua inicializado")
    world.queue_free()
    await process_frame
    if issues.is_empty():
        print("PASSOU: estrada orgânica, câmera e gameplay.")
        quit(0)
    else:
        quit(1)
