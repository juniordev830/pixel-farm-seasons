extends SceneTree
## Teste de montagem da camada visual da fazenda no Godot 4.3.
var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _check(ok: bool, label: String) -> void:
    if not ok:
        failures.append(label)
        push_error("VISUAL PASS TEST FAILED: " + label)


func _run() -> void:
    var scene := load("res://scenes/farm_world.tscn") as PackedScene
    _check(scene != null, "Cena farm_world.tscn disponivel")
    if scene == null:
        quit(1)
        return
    var world := scene.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    await process_frame
    var detail := world.get_node_or_null("VisualDetailPass") as Node3D
    _check(detail != null, "Script de detalhes conectado a cena")
    if detail != null:
        var roof_count := 0
        var lamps_count := 0
        var tree_count := 0
        var flower_count := 0
        for node in detail.get_children():
            if node is MultiMeshInstance3D:
                roof_count += 1
            if node is OmniLight3D:
                lamps_count += 1
            if String(node.name).begins_with("Copa do pomar"):
                tree_count += 1
            if String(node.name).begins_with("Flor de vaso"):
                flower_count += 1
        _check(roof_count >= 3, "Telhas instanciadas no telhado principal e varanda")
        _check(lamps_count >= 5, "Iluminacao quente em lampioes")
        _check(tree_count >= 7, "Pomar com arvores")
        _check(flower_count >= 15, "Vasos de flores")
        for child in detail.get_children():
            if child is MultiMeshInstance3D:
                _check(child.multimesh != null and child.multimesh.instance_count > 100,
                    "MultiMesh com instancias de telha")
    world.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASSOU: telhado ceramico, lanternas, pomar e vasos de flores.")
        quit(0)
    else:
        print("FALHAS: %s" % str(failures))
        quit(1)
