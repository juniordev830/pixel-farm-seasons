extends SceneTree
## Confere personagem estilizado na cena e componentes visuais.
var failures: Array[String] = []


func _initialize() -> void:
    call_deferred("_run")


func _expect(condition: bool, description: String) -> void:
    if not condition:
        failures.append(description)
        push_error("FARMER ART TEST FAILED: " + description)


func _run() -> void:
    var scene := load("res://scenes/farm_world.tscn") as PackedScene
    _expect(scene != null, "Cena carregada")
    if scene == null:
        quit(1)
        return
    var world := scene.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    await process_frame
    var player := world.get_node_or_null("Farmer/Visuals/FarmerArt") as Node3D
    _expect(player != null, "Modelo procedimental vinculado a Farmer")
    if player != null:
        _expect(player.get_node_or_null("PernaEsquerda") != null, "Perna esquerda")
        _expect(player.get_node_or_null("PernaDireita") != null, "Perna direita")
        _expect(player.get_node_or_null("BracoEsquerdo") != null, "Braco esquerdo")
        _expect(player.get_node_or_null("BracoDireito") != null, "Braco direito")
        _expect(player.get_child_count() > 10, "Acessorios e vestuario presentes")
    var old_body := world.get_node_or_null("Farmer/Visuals/Body") as Node3D
    _expect(old_body != null and not old_body.visible, "Cilindro antigo escondido")
    world.queue_free()
    await process_frame
    if failures.is_empty():
        print("PASSOU: novo modelo de fazendeiro carregado com membros e acessorios.")
        quit(0)
    else:
        quit(1)
