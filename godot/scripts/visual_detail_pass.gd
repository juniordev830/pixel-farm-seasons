extends Node3D
## Pixel Farm Seasons — art pass 01, detalhes visuais procedurais (Godot 4.3+).
## Aumenta a identidade da fazenda brasileira sem assets de terceiros.
## Malhas estaticas, sem novas colisoes, nao muda a jogabilidade da horta.

const ROOF_TILE := Color("#bd633e")
const ROOF_ALT := Color("#a84d34")
const WOOD := Color("#78462b")
const DARK_WOOD := Color("#533727")
const LEAF := Color("#438447")
const LEAF_LIGHT := Color("#78a953")
const FLOWERS := [
    Color("#f2d44b"), Color("#ee8466"),
    Color("#efbed0"), Color("#faf4df")
]
var rng := RandomNumberGenerator.new()


func _ready() -> void:
    rng.seed = 26051105
    call_deferred("_build_detail_pass")


func _mat(tint: Color, glow: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = tint
    m.roughness = 0.72
    if glow:
        m.emission_enabled = true
        m.emission = tint
        m.emission_energy_multiplier = 0.8
    return m


func _box(n: String, position_3d: Vector3, size: Vector3, tint: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = "%s_%04d" % [n, get_child_count()]
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = position_3d
    node.material_override = _mat(tint)
    add_child(node)
    return node


func _ball(n: String, position_3d: Vector3, size: Vector3, tint: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = "%s_%04d" % [n, get_child_count()]
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 10
    mesh.rings = 6
    node.mesh = mesh
    node.position = position_3d
    node.scale = size
    node.material_override = _mat(tint)
    add_child(node)
    return node


func _cylinder(n: String, position_3d: Vector3, radius: float, height: float, tint: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = "%s_%04d" % [n, get_child_count()]
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 12
    node.mesh = mesh
    node.position = position_3d
    node.material_override = _mat(tint)
    add_child(node)
    return node


func _build_detail_pass() -> void:
    _roof_tiles()
    _exterior_architecture()
    _warm_lanterns()
    _flower_beds()
    _porch_decorations()
    _paving_stones()
    _orchard_and_vegetation()
    _barn_details()


func _roof_tiles() -> void:
    # MultiMesh permite cobrir telhados sem centenas de draw calls.
    _roof_side("Telhas da casa lado oeste", Vector3(-17.45, 6.02, -14), 0.46)
    _roof_side("Telhas da casa lado leste", Vector3(-12.55, 6.02, -14), -0.46)
    # Telhado da varanda, curvo em fileiras de telhas vermelhas.
    var tile := BoxMesh.new()
    tile.size = Vector3(0.34, 0.07, 0.48)
    var multi := MultiMesh.new()
    multi.transform_format = MultiMesh.TRANSFORM_3D
    multi.use_colors = true
    multi.mesh = tile
    multi.instance_count = 24 * 7
    var i := 0
    for row in range(7):
        for col in range(24):
            var x := -19.75 + float(col) * 0.415
            var z := -8.82 + float(row) * 0.52
            var tile_xform := Transform3D(Basis.IDENTITY, Vector3(x, 3.44, z))
            multi.set_instance_transform(i, tile_xform)
            multi.set_instance_color(i, ROOF_TILE if (row + col) % 5 != 0 else ROOF_ALT)
            i += 1
    var node := MultiMeshInstance3D.new()
    node.name = "Telhas de ceramica da varanda"
    var porch_mat := _mat(ROOF_TILE)
    porch_mat.vertex_color_use_as_albedo = true
    tile.material = porch_mat
    node.multimesh = multi
    add_child(node)


func _roof_side(n: String, center: Vector3, angle: float) -> void:
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.43, 0.085, 0.52)
    var roof_mat := _mat(ROOF_TILE)
    roof_mat.vertex_color_use_as_albedo = true
    mesh.material = roof_mat
    var multi := MultiMesh.new()
    multi.transform_format = MultiMesh.TRANSFORM_3D
    multi.use_colors = true
    multi.mesh = mesh
    multi.instance_count = 10 * 15
    var rotation_basis := Basis(Vector3.FORWARD, angle)
    var index := 0
    for col in range(10):
        for row in range(15):
            var local := Vector3(-2.47 + float(col) * 0.54, 0.17, -3.68 + float(row) * 0.53)
            var xform := Transform3D(rotation_basis, center + rotation_basis * local)
            multi.set_instance_transform(index, xform)
            multi.set_instance_color(index, ROOF_TILE if (col + row) % 7 else ROOF_ALT)
            index += 1
    var node := MultiMeshInstance3D.new()
    node.name = "%s_%04d" % [n, get_child_count()]
    node.multimesh = multi
    add_child(node)


func _exterior_architecture() -> void:
    # Acabamentos de madeira e batentes inspirados na referencia aprovada.
    for yy in [1.58, 4.0]:
        for xx in [-17.90, -12.10]:
            _box("Veneziana esquerda", Vector3(xx - 1.13, yy, -10.21),
                Vector3(0.39, 1.69, 0.09), Color("#386889"))
            _box("Veneziana direita", Vector3(xx + 1.13, yy, -10.21),
                Vector3(0.39, 1.69, 0.09), Color("#386889"))
            for j in range(8):
                var y: float = float(yy) - 0.69 + float(j) * 0.19
                _box("Ripas das venezianas", Vector3(xx - 1.13, y, -10.16),
                    Vector3(0.33, 0.04, 0.06), Color("#224e68"))
                _box("Ripas das venezianas", Vector3(xx + 1.13, y, -10.16),
                    Vector3(0.33, 0.04, 0.06), Color("#224e68"))
    # Balcones e guarda-corpo da varanda superior.
    _box("Travessa da sacada", Vector3(-15, 3.97, -7.27),
        Vector3(9.1, 0.16, 0.22), WOOD)
    _box("Travessa baixa", Vector3(-15, 3.29, -7.27),
        Vector3(9.1, 0.12, 0.18), DARK_WOOD)
    for i in range(20):
        var x := -19.3 + float(i) * 0.45
        _box("Balaustre sacada", Vector3(x, 3.58, -7.27),
            Vector3(0.10, 0.7, 0.10), WOOD)
    for xx in [-19.46, -10.54]:
        _box("Viga telhado varanda", Vector3(xx, 3.39, -8.1),
            Vector3(0.22, 0.19, 3.2), DARK_WOOD)


func _warm_lanterns() -> void:
    for p in [
        Vector3(-18.5, 2.47, -10.16),
        Vector3(-11.4, 2.47, -10.16),
        Vector3(-17.8, 4.66, -10.23),
        Vector3(-12.2, 4.66, -10.23),
        Vector3(-25.0, 2.78, -5.5)
    ]:
        _box("Suporte lampiao", p + Vector3(0, 0.3, -0.04),
            Vector3(0.11, 0.5, 0.16), DARK_WOOD)
        _box("Lanterna base", p, Vector3(0.28, 0.10, 0.30), WOOD)
        _box("Vidro aceso", p + Vector3(0, 0.16, 0), Vector3(0.23, 0.35, 0.24), Color("#ffd08a"))
        var light := OmniLight3D.new()
        light.name = "Luz quente de lampiao"
        light.position = p + Vector3(0, 0.2, 0.2)
        light.light_color = Color("#ffbf72")
        light.light_energy = 0.24
        light.omni_range = 5.2
        light.shadow_enabled = false
        add_child(light)


func _flower_beds() -> void:
    # Vasos de terracota e flores coloridas fora da area de circulacao.
    for p in [
        Vector3(-20.15, 0.30, -7.10),
        Vector3(-9.90, 0.30, -7.10),
        Vector3(-18.1, 0.30, -7.10),
        Vector3(-12.2, 0.30, -7.10)
    ]:
        _cylinder("Vaso de terracota", p, 0.34, 0.55, Color("#ba724a"))
        _ball("Folhas do vaso", p + Vector3(0, 0.51, 0), Vector3(0.72, 0.45, 0.66), LEAF)
        for j in range(5):
            var a := float(j) * TAU / 5
            _ball("Flor de vaso", p + Vector3(cos(a) * 0.21, 0.72, sin(a) * 0.20),
                Vector3(0.14, 0.14, 0.14), FLOWERS[j % FLOWERS.size()])
    for i in range(38):
        var x := rng.randf_range(-24.0, -5.0)
        var z := rng.randf_range(-3.0, 3.3)
        if absf(x + 4.0) < 3.5 or x > -8.0:
            continue
        var p := Vector3(x, 0.08, z)
        _ball("Arbusto florido", p, Vector3(0.65, 0.32, 0.57), LEAF)
        _ball("Flor selvagem", p + Vector3(0.12, 0.27, -0.08),
            Vector3(0.15, 0.17, 0.14), FLOWERS[i % FLOWERS.size()])


func _porch_decorations() -> void:
    # Banco, jardineiras e suporte cenografico para a rede ja existente.
    _box("Jardineira da varanda", Vector3(-18.95, 0.68, -8.95),
        Vector3(1.50, 0.42, 0.40), WOOD)
    _ball("Plantas de jardineira", Vector3(-18.95, 0.94, -8.95),
        Vector3(1.42, 0.55, 0.51), LEAF)
    _box("Mesinha da varanda", Vector3(-10.9, 0.76, -8.4),
        Vector3(0.68, 0.10, 0.68), WOOD)
    _box("Xicara na varanda", Vector3(-10.9, 0.86, -8.4),
        Vector3(0.17, 0.13, 0.17), Color("#f8e5cc"))


func _paving_stones() -> void:
    # Pedras naturais ao lado do caminho principal, com tons alternados.
    for i in range(45):
        var z := 1.1 - float(i) * 0.18
        var x := -15.8 + rng.randf_range(-1.8, 1.8)
        var stone := _box("Pedra da trilha", Vector3(x, 0.055, z),
            Vector3(rng.randf_range(0.28, 0.51), 0.07, rng.randf_range(0.25, 0.47)),
            Color("#c7af8b") if i % 3 else Color("#b1a189"))
        stone.rotation.y = rng.randf_range(-0.45, 0.45)


func _orchard_and_vegetation() -> void:
    # Pomar pequeno para criar silhuetas e profundidade entre casa e horta.
    for i in range(7):
        var x := -30.0 - float(i % 4) * 2.0
        var z := -25.0 + float(i / 4) * 4.0
        _cylinder("Tronco do pomar", Vector3(x, 1.2, z), 0.20, 2.4, WOOD)
        _ball("Copa do pomar", Vector3(x, 3.0, z),
            Vector3(2.50, 2.20, 2.45), LEAF_LIGHT)
        for j in range(3):
            _ball("Fruta do pomar", Vector3(x + rng.randf_range(-0.8, 0.8),
                2.6 + rng.randf_range(-0.65, 0.65), z + rng.randf_range(-0.8, 0.8)),
                Vector3(0.21, 0.21, 0.21), Color("#dca044"))
    for i in range(32):
        var x := rng.randf_range(-42.0, 42.0)
        var z := rng.randf_range(-43.0, 43.0)
        if absf(x) < 25.0 and absf(z) < 26.0:
            continue
        _ball("Tufo de capim", Vector3(x, 0.18, z),
            Vector3(0.48, 0.48, 0.44), LEAF_LIGHT)


func _barn_details() -> void:
    # Molduras contrastantes do celeiro, preservando a entrada da fazenda.
    _box("Moldura alta celeiro", Vector3(17.0, 4.15, -11.25),
        Vector3(7.4, 0.19, 0.12), Color("#e9dbc8"))
    for xx in [13.7, 20.3]:
        _box("Batente celeiro", Vector3(xx, 2.15, -11.25),
            Vector3(0.20, 3.65, 0.20), Color("#eee1c5"))
    for z in [-11.2, -18.8]:
        _box("Sinalizacao de madeira", Vector3(24.8, 1.17, z),
            Vector3(0.13, 1.7, 1.4), WOOD)
