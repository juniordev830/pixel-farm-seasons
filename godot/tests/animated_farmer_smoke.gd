extends SceneTree
## Verify real rigged character and cinematic camera in the playable scene.
var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _expect(condition: bool, description: String) -> void:
    if not condition:
        failures.append(description)
        push_error("ANIMATED FARMER TEST FAILED: " + description)


func _run() -> void:
    var packed := load("res://scenes/farm_world.tscn") as PackedScene
    _expect(packed != null, "farm scene loads")
    if packed == null:
        quit(1)
        return
    var farm := packed.instantiate()
    root.add_child(farm)
    for i in range(12):
        await process_frame
    var character := farm.get_node_or_null("Farmer/Visuals/FarmerArt")
    var camera := farm.get_node_or_null("Farmer/CameraPivot/SpringArm3D/Camera3D") as Camera3D
    _expect(character != null, "character art node exists")
    _expect(camera != null and camera.fov <= 65.0, "camera has tighter cinematic perspective")
    var farmer := farm.get_node_or_null("Farmer") as CharacterBody3D
    var camera_arm := farm.get_node_or_null("Farmer/CameraPivot/SpringArm3D") as SpringArm3D
    _expect(camera_arm != null and camera_arm.spring_length >= 4.0, "camera starts behind farmer")
    if farmer != null and camera_arm != null:
        var toggle_event := InputEventAction.new()
        toggle_event.action = "toggle_camera"
        toggle_event.pressed = true
        farmer._unhandled_input(toggle_event)
        for i in range(20):
            await physics_frame
        _expect(camera_arm.spring_length >= 4.0, "V cannot switch camera to first person")
        _expect(farmer.get_node("Visuals").visible, "farmer remains visible in third person")
        # Regression: third-person lock must not disable mouse look or pitch limits.
        var pivot := farmer.get_node("CameraPivot") as Node3D
        var original_yaw := farmer.rotation.y
        var look_event := InputEventMouseMotion.new()
        look_event.relative = Vector2(120.0, -80.0)
        look_event.screen_relative = Vector2(40.0, -20.0)
        _expect(farmer.call("_mouse_motion_delta", look_event) == look_event.screen_relative,
            "camera input uses unscaled screen-relative mouse motion")
        _expect(farmer.call("_mouse_motion_delta", look_event) != look_event.relative,
            "camera ignores resolution-scaled mouse motion")
        farmer.call("_apply_mouse_look", farmer.call("_mouse_motion_delta", look_event))
        _expect(not is_equal_approx(farmer.rotation.y, original_yaw), "mouse still rotates farmer and rear camera")
        _expect(is_equal_approx(farmer.rotation.y, original_yaw - 40.0 * float(farmer.get("mouse_sensitivity"))),
            "camera yaw follows unscaled mouse delta")
        _expect(pivot.rotation.x >= float(farmer.get("min_pitch")) and pivot.rotation.x <= float(farmer.get("max_pitch")),
            "mouse look keeps camera pitch within configured limits")
        look_event.relative = Vector2(0.0, 10000.0)
        farmer.call("_apply_mouse_look", look_event.relative)
        _expect(is_equal_approx(pivot.rotation.x, float(farmer.get("min_pitch"))), "camera cannot look below minimum pitch")
        look_event.relative = Vector2(0.0, -10000.0)
        farmer.call("_apply_mouse_look", look_event.relative)
        _expect(is_equal_approx(pivot.rotation.x, float(farmer.get("max_pitch"))), "camera cannot look above maximum pitch")
        _expect(camera_arm.spring_length >= 4.0, "mouse look preserves third-person camera distance")
    if character != null:
        var model := character.get("imported_model") as Node3D
        var player := character.get("animation_player") as AnimationPlayer
        _expect(model != null and model.name == "FazendeiroAnimado", "rigged farmer loaded from real GLB")
        _expect(player != null, "AnimationPlayer loaded from character asset")
        if player != null:
            _expect(not String(character.call("_choose_animation", "idle")).is_empty(), "idle animation available")
            _expect(not String(character.call("_choose_animation", "walk")).is_empty(), "walking animation available")
            _expect(not String(character.call("_choose_animation", "sprint")).is_empty(), "running animation available")
    var sky_clouds := 0
    for child in farm.get_children():
        if String(child.get_meta("native_prop", child.name)).begins_with("Nuvem parte"):
            sky_clouds += 1
    _expect(sky_clouds == 0, "old oval cloud blocks removed")
    var dirt := farm.get_node_or_null("Estrada da fazenda") as MeshInstance3D
    _expect(dirt != null and dirt.material_override is ShaderMaterial, "dirt path uses non-blocky shader")
    farm.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASSOU: animated farmer, third-person camera, walk, sprint, sky and path shading.")
        quit(0)
    else:
        print("FALHAS: ", failures)
        quit(1)
