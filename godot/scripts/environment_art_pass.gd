extends Node3D
## Environmental art pass 02. Vegetation and small ground detail instanced via
## MultiMesh, so the farm feels less flat without requiring a dedicated GPU.
## Purely cosmetic: no collisions, no changes to farming, movement or saves.

const GRASS_TONES := [
    Color("#487a43"), Color("#64934d"), Color("#89a75e"), Color("#8da269")
]
const GRAVEL_TONES := [
    Color("#a99176"), Color("#b39e83"), Color("#917d68"), Color("#bea78c")
]
const BLOSSOMS := [
    Color("#eac666"), Color("#f7e6c0"), Color("#d88378"), Color("#c7b6d8")
]
var rng := RandomNumberGenerator.new()


func _ready() -> void:
    rng.seed = 6112026
    call_deferred("_build_environment")


func _ground_available(x: float, z: float) -> bool:
    if absf(x) > 47.0 or absf(z) > 47.0:
        return false
    # Roads, porch, garage, barn, fields, pen and pond stay clear.
    if x > -6.8 and x < -1.0 and z > -4.0 and z < 40.0:
        return false
    if x > -22.0 and x < -7.5 and z > -20.0 and z < -5.0:
        return false
    if x > -31.0 and x < -19.0 and z > -10.0 and z < 0.0:
        return false
    if x > 4.5 and x < 18.0 and z > -4.0 and z < 12.5:
        return false
    if x > 9.0 and x < 26.0 and z > 10.0 and z < 25.5:
        return false
    if x > 10.0 and x < 28.0 and z > -23.0 and z < -8.0:
        return false
    if Vector2(x + 24.0, (z - 15.0) * 1.3).length() < 6.2:
        return false
    return true


func _make_multimesh(label: String, mesh: Mesh, count: int, mat: Material) -> MultiMeshInstance3D:
    mesh.surface_set_material(0, mat)
    var mm := MultiMesh.new()
    mm.transform_format = MultiMesh.TRANSFORM_3D
    mm.use_colors = true
    mm.mesh = mesh
    mm.instance_count = count
    var node := MultiMeshInstance3D.new()
    node.name = label
    node.multimesh = mm
    add_child(node)
    return node


func _tinted_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.WHITE
    material.vertex_color_use_as_albedo = true
    material.roughness = 1.0
    material.cull_mode = BaseMaterial3D.CULL_DISABLED
    return material


func _build_environment() -> void:
    _paint_ground()
    _road_details()
    _flowers()
    _dry_field_edges()


func _grass_blades() -> ArrayMesh:
    # Pointed leaf blades replace rectangular sticks; each tuft has three
    # angled triangular leaves. All tufts share the same 6-triangle mesh.
    var mesh_builder := SurfaceTool.new()
    mesh_builder.begin(Mesh.PRIMITIVE_TRIANGLES)
    for j in range(3):
        var angle := float(j) * TAU / 3.0
        var side := Vector3(cos(angle), 0, sin(angle))
        var across := Vector3(-sin(angle), 0, cos(angle))
        var base := side * 0.085
        var tip := side * 0.18 + Vector3(0, 0.36, 0)
        for sign_index in range(2):
            var signed := 1.0 if sign_index == 0 else -1.0
            mesh_builder.add_vertex(base + across * 0.078 * signed)
            mesh_builder.add_vertex(base - across * 0.078 * signed)
            mesh_builder.add_vertex(tip)
    mesh_builder.generate_normals()
    return mesh_builder.commit()


func _paint_ground() -> void:
    # Instanced tapering leaves, no collision and low GPU overhead.
    var blade_mesh := _grass_blades()
    var spots: Array[Vector3] = []
    for i in range(4100):
        var x := rng.randf_range(-47.0, 47.0)
        var z := rng.randf_range(-47.0, 47.0)
        if _ground_available(x, z):
            spots.append(Vector3(x, 0.02, z))
    for side in range(2):
        var node := _make_multimesh("Capim instanciado %d" % side, blade_mesh, spots.size(), _tinted_material())
        var mm := node.multimesh
        for i in range(spots.size()):
            var height := rng.randf_range(0.40, 1.05)
            var angle := rng.randf_range(-PI, PI) + float(side) * PI * 0.5
            var offset := Vector3(0.12 if side else -0.12, 0, 0)
            var xf := Transform3D(Basis(Vector3.UP, angle).scaled(Vector3(1.0, height, 1.0)), spots[i] + offset)
            mm.set_instance_transform(i, xf)
            mm.set_instance_color(i, GRASS_TONES[rng.randi_range(0, GRASS_TONES.size() - 1)])


func _road_details() -> void:
    # Small gravel breaks up the large monochrome brown road.
    var stone := BoxMesh.new()
    stone.size = Vector3(0.14, 0.025, 0.09)
    var count := 100
    var node := _make_multimesh("Cascalho no caminho", stone, count, _tinted_material())
    var mm := node.multimesh
    for i in range(count):
        var x := rng.randf_range(-6.0, -2.0)
        var z := rng.randf_range(-2.0, 35.0)
        var xf := Transform3D(Basis(Vector3.UP, rng.randf_range(-PI, PI)).scaled(
            Vector3(rng.randf_range(0.45, 1.5), 1.0, rng.randf_range(0.6, 1.8))),
            Vector3(x, 0.045, z))
        mm.set_instance_transform(i, xf)
        mm.set_instance_color(i, GRAVEL_TONES[rng.randi_range(0, GRAVEL_TONES.size() - 1)])


func _flowers() -> void:
    var head := SphereMesh.new()
    head.radius = 0.065
    head.height = 0.13
    head.radial_segments = 6
    head.rings = 4
    var locations: Array[Vector3] = []
    for i in range(600):
        var x := rng.randf_range(-43, 43)
        var z := rng.randf_range(-43, 43)
        if _ground_available(x, z):
            locations.append(Vector3(x, rng.randf_range(0.13, 0.24), z))
    var node := _make_multimesh("Flores silvestres", head, locations.size(), _tinted_material())
    for i in range(locations.size()):
        node.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, locations[i]))
        node.multimesh.set_instance_color(i, BLOSSOMS[rng.randi_range(0, BLOSSOMS.size() - 1)])


func _dry_field_edges() -> void:
    # Natural, irregular margin between cultivated soil and the grass.
    var pebbles := BoxMesh.new()
    pebbles.size = Vector3(0.17, 0.09, 0.16)
    var count := 160
    var node := _make_multimesh("Pedras entre os canteiros", pebbles, count, _tinted_material())
    for i in range(count):
        var t := rng.randf()
        var x := rng.randf_range(5.8, 16.4) if t < 0.5 else (5.55 if t < 0.75 else 16.65)
        var z := (-1.8 if t < 0.25 else 10.8) if t < 0.5 else rng.randf_range(-1.5, 10.5)
        var xf := Transform3D(Basis(Vector3.UP, rng.randf_range(-PI, PI)),
            Vector3(x + rng.randf_range(-0.20, 0.20), 0.07, z + rng.randf_range(-0.20, 0.20)))
        node.multimesh.set_instance_transform(i, xf)
        node.multimesh.set_instance_color(i, GRAVEL_TONES[i % GRAVEL_TONES.size()])
