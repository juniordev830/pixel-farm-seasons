extends SceneTree
## Ensures detailed GLB models replace primitives in the playable 3D scene.
var errors: Array[String] = []


func _initialize() -> void:
    call_deferred("_check_world")


func _check(ok: bool, label: String) -> void:
    if not ok:
        errors.append(label)
        push_error("QUALITY ASSET TEST FAILED: " + label)


func _check_world() -> void:
    var world_scene := load("res://scenes/farm_world.tscn") as PackedScene
    _check(world_scene != null, "3D farm scene loads")
    if world_scene == null:
        quit(1)
        return
    var world := world_scene.instantiate()
    root.add_child(world)
    for i in range(10):
        await process_frame
    var assets := world.get_node_or_null("AssetQualityPass") as Node3D
    _check(assets != null, "Asset quality pass connected")
    if assets != null:
        _check(int(assets.tree_count) >= 10, "Imported 3D trees replace primitive canopies")
        _check(int(assets.flower_count) >= 10, "3D flowers populate the terrain")
        _check(int(assets.rocks_count) >= 1, "3D stones populate ground")
        _check(bool(assets.car_upgraded), "Fusca rendered with curved shapes")
        var loaded_models := 0
        for node in assets.get_children():
            if String(node.get_meta("asset_id", "")).ends_with(".glb"):
                loaded_models += 1
        _check(loaded_models >= 30, "Detailed GLB props are active in world")
    var sim := world.get_node_or_null("LifeSim")
    _check(sim != null and bool(sim.initialized), "Existing gameplay initialized")
    if sim != null:
        var car := sim.get_node_or_null("Carro dirigivel")
        _check(car != null and car is CharacterBody3D, "Car collision and controls preserved")
        if car != null:
            _check(car.get_node_or_null("Fusca carroceria arredondada") != null, "Rounded car visible")
    var garden := world.get_node_or_null("FarmingSystem")
    _check(garden != null, "Playable farming system preserved")
    world.queue_free()
    await process_frame
    if errors.is_empty():
        print("PASSOU: novos modelos 3D, arvores, flores, pedras, carro e gameplay.")
        quit(0)
    else:
        print("FALHAS: ", errors)
        quit(1)
