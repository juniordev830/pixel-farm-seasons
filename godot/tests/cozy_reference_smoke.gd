extends SceneTree
## Checks that the approved cozy art direction is actually attached to
## the playable 3D scene, not just present in documentation or concept art.
var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _check(ok: bool, label: String) -> void:
    if not ok:
        failures.append(label)
        push_error("COZY REFERENCE TEST FAILED: " + label)


func _run() -> void:
    var packed := load("res://scenes/farm_world.tscn") as PackedScene
    _check(packed != null, "Main 3D scene imports")
    if packed == null:
        quit(1)
        return
    var world := packed.instantiate()
    root.add_child(world)
    for i in range(8):
        await process_frame
    var art := world.get_node_or_null("CozyReferenceArt") as Node3D
    _check(art != null, "Cozy visual art connected to live world")
    if art != null:
        var wooden_beds := 0
        var blossoms := 0
        var garage_flowers := 0
        var barn_details := 0
        for node in art.get_children():
            var title := String(node.get_meta("cozy_kind", node.name))
            if title.begins_with("Canteiro elevado"):
                wooden_beds += 1
            if title.begins_with("Cerejeira"):
                blossoms += 1
            if title.begins_with("Cachos floridos garagem"):
                garage_flowers += 1
            if title.begins_with("Trava diagonal"):
                barn_details += 1
        _check(wooden_beds >= 120, "30 raised wooden garden beds")
        _check(blossoms >= 20, "Flowering spring trees in world")
        _check(garage_flowers >= 10, "Flowering garage pergola")
        _check(barn_details >= 2, "Detailed barn front")
    var terrain := world.get_node_or_null("Terreno principal") as MeshInstance3D
    _check(terrain != null and terrain.material_override is ShaderMaterial, "Grass shader applied to actual terrain")
    var lake := world.get_node_or_null("Lago de agua azul") as MeshInstance3D
    _check(lake != null, "Lago continua na cena")
    _check(lake != null and lake.material_override is ShaderMaterial,
        "Lago usa shader animado de agua")
    if lake != null and lake.material_override is ShaderMaterial:
        var lake_shader := (lake.material_override as ShaderMaterial).shader
        _check(lake_shader != null, "Recurso de agua carregado")
        if lake_shader != null:
            _check(lake_shader.resource_path == "res://shaders/water_stylized.gdshader",
                "Lago usa o shader correto, nao outro material")
    var hud := world.get_node_or_null("CozyGameHUD")
    _check(hud != null and hud.get_node_or_null("CozyOverlay/QuickTools") != null,
        "Quick farming toolbar visible in live HUD")
    world.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASSOU: wooden garden beds, spring trees, garage flowers, barn, ground shader and HUD.")
        quit(0)
    else:
        print("FALHAS: %s" % str(failures))
        quit(1)
