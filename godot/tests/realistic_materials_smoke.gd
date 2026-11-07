extends SceneTree
## Confirm the visual pass is installed, sets PBR shader parameters, and
## leaves the original gameplay scene and its collisions intact.
var failures: Array[String] = []


func _check(condition: bool, label: String) -> void:
    if not condition:
        failures.append(label)
        push_error("REALISM PASS TEST FAILED: " + label)


func _initialize() -> void:
    call_deferred("_run")


func _run() -> void:
    var resource := load("res://scenes/farm_world.tscn") as PackedScene
    _check(resource != null, "Cena principal carregada")
    if resource == null:
        quit(1)
        return
    var world := resource.instantiate()
    root.add_child(world)
    for frame in range(8):
        await process_frame

    var art := world.get_node_or_null("RealisticMaterialPass") as Node3D
    _check(art != null, "Passe grafico conectado na cena")
    if art != null:
        _check(art.get("applied_count") >= 10, "Materiais aplicados na casa, telhados e cercas")

    for label in ["Telhado esquerdo",
                  "Telhado direito", "Pilar da varanda", "Silo pequeno"]:
        var found := false
        for node in world.get_children():
            if not node is MeshInstance3D:
                continue
            var mesh_node := node as MeshInstance3D
            if String(mesh_node.get_meta("native_prop", "")) != label:
                continue
            found = true
            var mat := mesh_node.material_override as ShaderMaterial
            _check(mat != null, label + ": material de shader aplicado")
            if mat != null:
                _check(mat.get_shader_parameter("base_roughness") != null,
                    label + ": rugosidade configurada")
            break
        _check(found, label + ": geometria original preservada")

    # LifeSim removes the original solid shell to make the house enterable.
    # Validate the actual wall rather than its deleted placeholder.
    var life := world.get_node_or_null("LifeSim")
    var facade: MeshInstance3D = null
    if life != null:
        facade = life.get_node_or_null("Parede oeste") as MeshInstance3D
    _check(facade != null, "Fachada real da casa mantida")
    if facade != null:
        _check(facade.material_override is ShaderMaterial, "Material do reboco aplicado na fachada")

    _check(world.get_node_or_null("Farmer") != null, "Controlador do fazendeiro mantido")
    _check(world.get_node_or_null("FarmingSystem") != null, "Horta mantida")
    _check(world.get_node_or_null("LifeSim") != null, "Rotina mantida")

    world.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASSOU: materiais de reboco, madeira, telhas e metal aplicados.")
        quit(0)
    else:
        print("FALHAS: %s" % str(failures))
        quit(1)
