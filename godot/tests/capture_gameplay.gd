extends SceneTree
## Captura imagens reais do prototipo Godot em execucao (sem mockups).
## Necessita display X11/Xvfb, nao use --headless.

func _initialize() -> void:
    call_deferred("_capture")


func _frames(count: int) -> void:
    for i in range(count):
        await process_frame


func _save(frame_name: String) -> bool:
    await _frames(20)
    var viewport_image := root.get_texture().get_image()
    if viewport_image == null or viewport_image.get_width() < 320:
        push_error("CAPTURE FAILED: viewport rendered no image")
        return false
    var out_dir := OS.get_environment("GITHUB_WORKSPACE").path_join("screenshots")
    var error := DirAccess.make_dir_recursive_absolute(out_dir)
    if error != OK:
        push_error("CAPTURE FAILED: cannot create screenshot folder: " + str(error))
        return false
    var out_path := out_dir.path_join(frame_name)
    var saved := viewport_image.save_png(out_path)
    if saved != OK:
        push_error("CAPTURE FAILED: cannot write screenshot: " + out_path)
        return false
    print("CAPTURED:", out_path, " ", viewport_image.get_width(), "x", viewport_image.get_height())
    return true


func _capture() -> void:
    root.size = Vector2i(1280, 800)
    var packed := load("res://scenes/farm_world.tscn") as PackedScene
    if packed == null:
        push_error("CAPTURE FAILED: world scene missing")
        quit(1)
        return
    var world := packed.instantiate()
    root.add_child(world)
    await _frames(45)
    var farmer := world.get_node_or_null("Farmer") as CharacterBody3D
    var life := world.get_node_or_null("LifeSim")
    if farmer == null or life == null or not bool(life.get("initialized")):
        push_error("CAPTURE FAILED: gameplay did not initialize")
        quit(1)
        return

    # 1. Visao real de partida, da camera atras do fazendeiro.
    if not await _save("01-fazenda-camera-terceira-pessoa.png"):
        quit(1)
        return

    # 2. Vista da casa e varanda com personagem ao centro.
    farmer.global_position = Vector3(-14.5, 1.1, 6.0)
    farmer.rotation.y = 0.0
    life.call("_reset_travel_position")
    if not await _save("02-casa-varanda.png"):
        quit(1)
        return

    # 3. Vista da horta com canteiros ao lado direito.
    farmer.global_position = Vector3(8.5, 1.1, 18.0)
    farmer.rotation.y = 0.0
    life.call("_reset_travel_position")
    if not await _save("03-horta-canteiros.png"):
        quit(1)
        return

    # 4. Garagem com Fusca e Monark.
    farmer.global_position = Vector3(-24.5, 1.1, 4.0)
    farmer.rotation.y = 0.0
    life.call("_reset_travel_position")
    if not await _save("04-garagem-veiculos.png"):
        quit(1)
        return

    world.queue_free()
    await process_frame
    print("CAPTURE PASS: 4 actual in-engine gameplay screenshots exported.")
    quit(0)
