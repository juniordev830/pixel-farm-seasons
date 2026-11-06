extends Node3D
## Visual assets upgrade: original CC0 3D meshes replace primitive blocks.
## All geometry is cosmetic; gameplay, collisions, save data and car controls
## continue to use the original nodes and scripts.
## Assets: Kenney Nature Kit (CC0), from Hidencod/tge-assets.

const NATURE := "res://assets/kenney/nature/"
const TREES := [
    "tree-detailed.glb", "tree-oak.glb", "tree-plateau.glb",
    "tree-pineroundb.glb", "tree-default.glb", "tree-fat.glb"
]
const FLOWERS := ["flower-purpleb.glb", "flower-yellowb.glb", "flower-redb.glb"]
const ROCKS := ["rock-largea.glb", "rock-largeb.glb", "rock-smalla.glb"]
var rng := RandomNumberGenerator.new()
var loaded: Dictionary = {}
var tree_count := 0
var flower_count := 0
var rocks_count := 0
var car_upgraded := false


func _ready() -> void:
    rng.seed = 20261106
    call_deferred("_apply")


func _packed(filename: String) -> PackedScene:
    if not loaded.has(filename):
        loaded[filename] = load(NATURE + filename)
    return loaded[filename] as PackedScene


func _place(filename: String, at: Vector3, size: float, spin: float = 0.0) -> Node3D:
    var scene := _packed(filename)
    if scene == null:
        push_error("NatureAssetPass: failed to import " + filename)
        return null
    var node := scene.instantiate() as Node3D
    if node == null:
        return null
    add_child(node)
    node.name = "3D asset " + filename.get_basename()
    node.position = at
    node.scale = Vector3.ONE * size
    node.rotation.y = spin
    return node


func _apply() -> void:
    # Root script and LifeSim use deferred construction. Give them one frame.
    await get_tree().process_frame
    await get_tree().process_frame
    _replace_generic_trees()
    _replace_orchard()
    _improve_cherry_trees()
    _add_detail_props()
    _round_off_car()


func _replace_generic_trees() -> void:
    var world := get_parent()
    var positions: Array[Vector3] = []
    var variations: Array[float] = []
    for node in world.get_children():
        if node is MeshInstance3D and String(node.name).begins_with("Tronco"):
            positions.append(Vector3(node.position.x, 0, node.position.z))
            variations.append(clampf(node.position.y / 1.4, 0.65, 1.45))
            node.visible = false
        elif node is MeshInstance3D and (String(node.name).begins_with("Copa baixa") or String(node.name).begins_with("Copa alta")):
            node.visible = false
    for i in range(positions.size()):
        var filename := String(TREES[i % TREES.size()])
        if _place(filename, positions[i], 4.7 * variations[i], rng.randf_range(-PI, PI)) != null:
            tree_count += 1


func _replace_orchard() -> void:
    var details := get_parent().get_node_or_null("VisualDetailPass") as Node3D
    if details == null:
        return
    var orchards: Array[Vector3] = []
    for node in details.get_children():
        if node is MeshInstance3D:
            var title := String(node.name)
            if title.begins_with("Tronco do pomar"):
                orchards.append(Vector3(node.position.x, 0, node.position.z))
            if title.begins_with("Tronco do pomar") or title.begins_with("Copa do pomar") or title.begins_with("Fruta do pomar"):
                node.visible = false
    for i in range(orchards.size()):
        if _place("tree-oak.glb" if i % 2 == 0 else "tree-detailed.glb", orchards[i], 4.2, float(i) * 0.77) != null:
            tree_count += 1


func _improve_cherry_trees() -> void:
    var details := get_parent().get_node_or_null("CozyReferenceArt") as Node3D
    if details == null:
        return
    var centers: Array[Vector3] = []
    for node in details.get_children():
        if node is MeshInstance3D and String(node.name).begins_with("Cerejeira"):
            if String(node.name).begins_with("Cerejeira tronco"):
                centers.append(Vector3(node.position.x, 0, node.position.z))
            node.visible = false
    # A smaller, more irregular blossom layer over a detailed imported tree.
    for center in centers:
        if _place("tree-detailed.glb", center, 5.1, rng.randf_range(0, TAU)) != null:
            tree_count += 1
    if centers.is_empty():
        return
    var petal_mesh := SphereMesh.new()
    petal_mesh.radius = 0.12
    petal_mesh.height = 0.24
    petal_mesh.radial_segments = 6
    petal_mesh.rings = 4
    var mat := StandardMaterial3D.new()
    mat.vertex_color_use_as_albedo = true
    mat.roughness = 1.0
    petal_mesh.material = mat
    var m := MultiMesh.new()
    m.transform_format = MultiMesh.TRANSFORM_3D
    m.use_colors = true
    m.mesh = petal_mesh
    m.instance_count = centers.size() * 150
    var index := 0
    for center in centers:
        for j in range(150):
            var radial := rng.randf_range(0.4, 2.6)
            var angle := rng.randf_range(0, TAU)
            var y := rng.randf_range(3.5, 6.5)
            var at := center + Vector3(cos(angle) * radial, y, sin(angle) * radial)
            var basis := Basis(Vector3.UP, rng.randf_range(0, TAU))
            basis = basis.scaled(Vector3.ONE * rng.randf_range(0.65, 1.25))
            m.set_instance_transform(index, Transform3D(basis, at))
            m.set_instance_color(index, Color("#ed9cb7") if j % 3 == 0 else Color("#f6c1d1"))
            index += 1
    var blossoms := MultiMeshInstance3D.new()
    blossoms.name = "Flores de primavera instanciadas"
    blossoms.multimesh = m
    add_child(blossoms)


func _add_detail_props() -> void:
    var environment := get_parent().get_node_or_null("EnvironmentArtPass")
    for i in range(105):
        var x := rng.randf_range(-44.0, 44.0)
        var z := rng.randf_range(-43.0, 43.0)
        if environment != null and not bool(environment.call("_ground_available", x, z)):
            continue
        var model := String(FLOWERS[i % FLOWERS.size()])
        if _place(model, Vector3(x, 0.02, z), rng.randf_range(1.7, 3.1), rng.randf_range(-PI, PI)) != null:
            flower_count += 1
    for i in range(35):
        var x := rng.randf_range(-43.0, 43.0)
        var z := rng.randf_range(-43.0, 43.0)
        if environment != null and not bool(environment.call("_ground_available", x, z)):
            continue
        var model := "plant-bushdetailed.glb" if i % 2 == 0 else "plant-bushlarge.glb"
        _place(model, Vector3(x, 0.0, z), rng.randf_range(2.0, 3.2), rng.randf_range(-PI, PI))
    for i in range(24):
        var x := rng.randf_range(-44.0, 44.0)
        var z := rng.randf_range(-43.0, 43.0)
        if environment != null and not bool(environment.call("_ground_available", x, z)):
            continue
        if _place(String(ROCKS[i % ROCKS.size()]), Vector3(x, 0.015, z), rng.randf_range(1.6, 3.5), rng.randf_range(-PI, PI)) != null:
            rocks_count += 1
    # Flowers near the porch and beds, carefully outside walking paths.
    for x in [-20.35, -19.8, -9.55, -8.95]:
        for z in [-6.4, -5.9, -5.4]:
            _place(String(FLOWERS[rng.randi_range(0, FLOWERS.size() - 1)]), Vector3(x, 0.08, z), 2.4, rng.randf_range(-PI, PI))
    # A handful of high-quality decorative crop models at the edge of the
    # vegetable plot; live planted crops remain controlled by FarmingSystem.
    for z in [1.5, 4.0, 6.5, 9.0]:
        _place("crops-cornstagec.glb", Vector3(17.3, 0.0, z), 1.6, rng.randf_range(0, TAU))


func _car_mesh(label: String, mesh: Mesh, at: Vector3, color: Color, car: Node3D, scale: Vector3 = Vector3.ONE) -> MeshInstance3D:
    var obj := MeshInstance3D.new()
    obj.name = label
    obj.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = 0.2
    mat.roughness = 0.36
    obj.material_override = mat
    car.add_child(obj)
    obj.position = at
    obj.scale = scale
    return obj


func _round_sphere(label: String, at: Vector3, size: Vector3, color: Color, car: Node3D) -> void:
    var sphere := SphereMesh.new()
    sphere.radius = 0.5
    sphere.height = 1.0
    sphere.radial_segments = 28
    sphere.rings = 16
    _car_mesh(label, sphere, at, color, car, size)


func _round_off_car() -> void:
    var sim := get_parent().get_node_or_null("LifeSim")
    if sim == null:
        return
    var car := sim.get_node_or_null("Carro dirigivel") as Node3D
    if car == null:
        return
    for node in car.get_children():
        if node is MeshInstance3D and (String(node.name).begins_with("Fusca azul") or String(node.name).begins_with("Parabrisa Fusca") or String(node.name).begins_with("Pneu carro")):
            node.visible = false
    var blue := Color("#5b9db4")
    _round_sphere("Fusca carroceria arredondada", Vector3(0, 0.12, 0), Vector3(1.79, 1.00, 3.42), blue, car)
    _round_sphere("Fusca teto curvado", Vector3(0, 0.71, 0.24), Vector3(1.48, 1.13, 1.93), Color("#79b2c4"), car)
    _round_sphere("Fusca capo", Vector3(0, 0.11, -1.14), Vector3(1.60, 0.70, 1.18), blue, car)
    _round_sphere("Fusca traseira", Vector3(0, 0.16, 1.17), Vector3(1.60, 0.82, 1.14), blue, car)
    for x in [-0.86, 0.86]:
        for z in [-1.07, 1.07]:
            var wheel := CylinderMesh.new()
            wheel.top_radius = 0.37
            wheel.bottom_radius = 0.37
            wheel.height = 0.23
            wheel.radial_segments = 24
            var tire := _car_mesh("Fusca pneu real", wheel, Vector3(x, -0.21, z), Color("#232527"), car)
            tire.rotation.z = PI * 0.5
            var hub := CylinderMesh.new()
            hub.top_radius = 0.19
            hub.bottom_radius = 0.19
            hub.height = 0.275
            hub.radial_segments = 24
            var wheelcap := _car_mesh("Fusca calota", hub, Vector3(x, -0.21, z), Color("#ccd6d4"), car)
            wheelcap.rotation.z = PI * 0.5
        _round_sphere("Farol circular dianteiro", Vector3(x * 0.75, 0.32, -1.55), Vector3(0.29, 0.23, 0.19), Color("#f1e3b7"), car)
        _round_sphere("Lanterna traseira", Vector3(x * 0.75, 0.25, 1.55), Vector3(0.24, 0.26, 0.18), Color("#be413c"), car)
    var window := BoxMesh.new()
    window.size = Vector3(1.06, 0.47, 0.06)
    var windshield := _car_mesh("Parabrisa arredondado", window, Vector3(0, 0.80, -0.62), Color("#81a5ab"), car)
    windshield.rotation.x = -0.34
    for x in [-0.735, 0.735]:
        var side := BoxMesh.new()
        side.size = Vector3(0.05, 0.42, 0.97)
        var side_window := _car_mesh("Janela lateral", side, Vector3(x, 0.80, 0.23), Color("#87a6ad"), car)
        side_window.rotation.z = -0.08 if x > 0 else 0.08
    car_upgraded = true
