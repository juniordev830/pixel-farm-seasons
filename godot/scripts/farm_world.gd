extends Node3D
## Fazenda 3D procedural (Godot 4.3+) — arte low-poly, sem assets externos.
## Os modelos sao temporarios: substitua-os por GLB/GLTF mantendo as posicoes.
## A cena respeita o controlador existente em scripts/farmer_controller.gd.

const GRASS := Color("#6c9f5c")
const GRASS_LIGHT := Color("#84ae67")
const WOOD := Color("#875b38")
const WOOD_LIGHT := Color("#c79964")
const SOIL := Color("#654631")
const CREAM := Color("#f5e4c2")
const ROOF := Color("#a9533a")
const LEAVES := Color("#4e8151")
const SKY := Color("#b4d5ed")

var rng := RandomNumberGenerator.new()


func _ready() -> void:
    rng.seed = 41822026
    _lighting()
    _terrain()
    _farmhouse()
    _barn()
    _fields()
    _animal_pen()
    _pond()
    _vehicle()
    _trees()
    _sky_details()


func _material(color: Color, metallic: float = 0.0) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.87
    mat.metallic = metallic
    return mat


func _box(label: String, at: Vector3, dimensions: Vector3, color: Color, solid: bool = false) -> MeshInstance3D:
    var obj := MeshInstance3D.new()
    obj.name = label
    var shape := BoxMesh.new()
    shape.size = dimensions
    obj.mesh = shape
    obj.material_override = _material(color)
    obj.position = at
    add_child(obj)
    if solid:
        var body := StaticBody3D.new()
        body.name = "Solid"
        var collision := CollisionShape3D.new()
        var box_shape := BoxShape3D.new()
        box_shape.size = dimensions
        collision.shape = box_shape
        body.add_child(collision)
        obj.add_child(body)
    return obj


func _ball(label: String, at: Vector3, dimensions: Vector3, color: Color) -> MeshInstance3D:
    var obj := MeshInstance3D.new()
    obj.name = label
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 10
    mesh.rings = 6
    obj.mesh = mesh
    obj.position = at
    obj.scale = dimensions
    obj.material_override = _material(color)
    add_child(obj)
    return obj


func _cylinder(label: String, at: Vector3, radius: float, height: float, color: Color, top_ratio: float = 1.0) -> MeshInstance3D:
    var obj := MeshInstance3D.new()
    obj.name = label
    var mesh := CylinderMesh.new()
    mesh.bottom_radius = radius
    mesh.top_radius = radius * top_ratio
    mesh.height = height
    mesh.radial_segments = 10
    obj.mesh = mesh
    obj.material_override = _material(color)
    obj.position = at
    add_child(obj)
    return obj


func _beam(label: String, a: Vector3, b: Vector3, thickness: float, color: Color) -> void:
    var delta := b - a
    if delta.length_squared() < 0.0001:
        return
    var beam := _box(label, (a + b) * 0.5, Vector3(thickness, delta.length(), thickness), color)
    beam.quaternion = Quaternion(Vector3.UP, delta.normalized())


func _lighting() -> void:
    var sun := DirectionalLight3D.new()
    sun.name = "Sun"
    sun.rotation_degrees = Vector3(-53.0, -27.0, 0.0)
    sun.light_color = Color("#fff1d4")
    sun.light_energy = 1.4
    sun.shadow_enabled = true
    add_child(sun)

    var world_environment := WorldEnvironment.new()
    world_environment.name = "WorldEnvironment"
    var env := Environment.new()
    # A true gradient sky replaces the solid dark-blue backdrop in gameplay.
    var sky := Sky.new()
    var sky_mat := ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color("#609cc6")
    sky_mat.sky_horizon_color = Color("#c8dfe4")
    sky_mat.ground_bottom_color = Color("#465638")
    sky_mat.ground_horizon_color = Color("#c8d4be")
    sky.sky_material = sky_mat
    env.sky = sky
    env.background_mode = Environment.BG_SKY
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#e7ebdb")
    env.ambient_light_energy = 0.82
    world_environment.environment = env
    add_child(world_environment)


func _terrain() -> void:
    _box("Terreno principal", Vector3(0, -0.18, 0), Vector3(100, 0.35, 100), GRASS, true)

    # Caminho de terra saindo do portao e levando ao casarao.
    _box("Estrada da fazenda", Vector3(-4, 0.015, 17), Vector3(4.5, 0.035, 40), Color("#b79b75"))
    _box("Caminho ate a varanda", Vector3(-9, 0.022, -7.5), Vector3(12.5, 0.04, 2.1), Color("#c3a57d"))
    for i in range(26):
        var x := rng.randf_range(-45.0, 45.0)
        var z := rng.randf_range(-45.0, 45.0)
        if absf(x) < 25.0 and absf(z) < 25.0:
            continue
        _ball("Vegetacao rasteira", Vector3(x, 0.08, z), Vector3(1.6, 0.16, 1.0), GRASS_LIGHT)


func _farmhouse() -> void:
    var x := -15.0
    var z := -14.0

    _box("Casa - paredes de dois pavimentos", Vector3(x, 2.7, z), Vector3(9.2, 5.4, 7.2), CREAM, true)
    _box("Faixa entre andares", Vector3(x, 2.7, z + 3.67), Vector3(9.4, 0.22, 0.18), WOOD_LIGHT)
    _box("Rodape da fachada", Vector3(x, 0.25, z + 3.69), Vector3(9.4, 0.38, 0.18), WOOD_LIGHT)

    # Telhado em duas aguas; e apenas cenografico neste MVP.
    var left := _box("Telhado esquerdo", Vector3(x - 2.45, 6.02, z), Vector3(5.7, 0.24, 8.1), ROOF)
    left.rotation.z = 0.46
    var right := _box("Telhado direito", Vector3(x + 2.45, 6.02, z), Vector3(5.7, 0.24, 8.1), ROOF)
    right.rotation.z = -0.46

    # Varanda com quatro pilares, madeira e cobertura.
    _box("Piso da varanda", Vector3(x, 0.16, z + 5.22), Vector3(10.1, 0.32, 3.4), WOOD_LIGHT, true)
    _box("Cobertura da varanda", Vector3(x, 3.27, z + 5.2), Vector3(10.1, 0.24, 3.65), ROOF)
    for pillar_x in [-19.6, -16.6, -13.4, -10.4]:
        _box("Pilar da varanda", Vector3(pillar_x, 1.66, z + 6.78), Vector3(0.22, 3.1, 0.22), WOOD, true)

    _box("Porta principal", Vector3(x, 1.3, z + 3.66), Vector3(1.65, 2.6, 0.12), WOOD)
    _ball("Macaneta", Vector3(x + 0.55, 1.29, z + 3.75), Vector3(0.12, 0.12, 0.12), Color("#e5b95b"))

    for yy in [1.58, 4.0]:
        for xx in [x - 2.9, x + 2.9]:
            _box("Moldura da janela", Vector3(xx, yy, z + 3.7), Vector3(1.82, 1.65, 0.18), WOOD_LIGHT)
            _box("Vidro azul", Vector3(xx, yy, z + 3.81), Vector3(1.53, 1.34, 0.08), Color("#82b7c7"))
            _box("Trilho vertical", Vector3(xx, yy, z + 3.9), Vector3(0.085, 1.45, 0.1), CREAM)
            _box("Trilho horizontal", Vector3(xx, yy, z + 3.9), Vector3(1.65, 0.08, 0.1), CREAM)

    # Banco e rede representados por malhas simples.
    _box("Banco varanda", Vector3(x - 3.0, 0.77, z + 5.4), Vector3(2.1, 0.15, 0.65), WOOD)
    _box("Pernas do banco", Vector3(x - 3.0, 0.37, z + 5.4), Vector3(1.9, 0.65, 0.12), WOOD)
    _box("Rede de descanso - placeholder", Vector3(x + 2.8, 1.0, z + 5.6), Vector3(2.7, 0.14, 1.1), Color("#edd7a1"))


func _barn() -> void:
    var x := 17.0
    var z := -15.0
    _box("Celeiro vermelho", Vector3(x, 2.45, z), Vector3(8.5, 4.9, 7.2), Color("#b4493c"), true)
    var a := _box("Celeiro - telhado esquerda", Vector3(x - 2.25, 5.43, z), Vector3(5.25, 0.24, 8.0), Color("#4b555f"))
    a.rotation.z = 0.47
    var b := _box("Celeiro - telhado direita", Vector3(x + 2.25, 5.43, z), Vector3(5.25, 0.24, 8.0), Color("#4b555f"))
    b.rotation.z = -0.47
    _box("Porta dupla", Vector3(x, 1.75, z + 3.67), Vector3(3.35, 3.5, 0.14), WOOD)
    _box("Divisoria das portas", Vector3(x, 1.75, z + 3.79), Vector3(0.12, 3.5, 0.11), WOOD_LIGHT)
    _box("Janela celeiro", Vector3(x, 3.72, z + 3.72), Vector3(1.4, 0.85, 0.12), Color("#e5d1a6"))
    _cylinder("Silo pequeno", Vector3(24.0, 3.2, -15.0), 2.0, 6.4, Color("#a9afb0"))
    _cylinder("Silo telhado", Vector3(24.0, 6.9, -15.0), 2.15, 1.0, Color("#647683"), 0.0)


func _crop_plant(at: Vector3, stage: int) -> void:
    _cylinder("Caule", at + Vector3(0, 0.24, 0), 0.04, 0.48, Color("#3e7835"))
    _ball("Folhas", at + Vector3(0, 0.48, 0), Vector3(0.4, 0.18, 0.32), Color("#4d943e"))
    if stage > 0:
        _ball("Folha lateral", at + Vector3(-0.16, 0.3, 0), Vector3(0.26, 0.1, 0.21), Color("#77ad48"))
    if stage > 1:
        _ball("Fruto", at + Vector3(0.03, 0.36, 0.11), Vector3(0.23, 0.23, 0.23), Color("#e98c41"))


func _fields() -> void:
    _box("Placa horta", Vector3(7.8, 0.65, -0.8), Vector3(2.6, 1.0, 0.18), WOOD_LIGHT)
    for row in range(5):
        for col in range(6):
            var x := 7.5 + float(col) * 1.58
            var z := 1.45 + float(row) * 1.85
            _box("Canteiro de terra", Vector3(x, 0.085, z), Vector3(1.3, 0.18, 1.52), SOIL)
            # Culturas sao criadas e atualizadas pelo FarmingSystem.

    _fence_x(5.8, 16.4, -1.6)
    _fence_z(5.8, -1.6, 10.6)
    _fence_z(16.4, -1.6, 10.6)
    # Entrada da horta fica aberta de proposito.
    _fence_x(5.8, 10.0, 10.6)
    _fence_x(12.5, 16.4, 10.6)


func _fence_x(start_x: float, end_x: float, z: float) -> void:
    var length := end_x - start_x
    var steps := maxi(1, int(ceilf(length / 2.0)))
    for i in range(steps + 1):
        var x := lerpf(start_x, end_x, float(i) / float(steps))
        _box("Mourao", Vector3(x, 0.57, z), Vector3(0.17, 1.14, 0.17), WOOD)
    for yy in [0.43, 0.85]:
        _box("Travessa da cerca", Vector3((start_x + end_x) * 0.5, yy, z), Vector3(length, 0.12, 0.1), WOOD_LIGHT)


func _fence_z(x: float, start_z: float, end_z: float) -> void:
    var length := end_z - start_z
    var steps := maxi(1, int(ceilf(length / 2.0)))
    for i in range(steps + 1):
        var z := lerpf(start_z, end_z, float(i) / float(steps))
        _box("Mourao", Vector3(x, 0.57, z), Vector3(0.17, 1.14, 0.17), WOOD)
    for yy in [0.43, 0.85]:
        _box("Travessa da cerca", Vector3(x, yy, (start_z + end_z) * 0.5), Vector3(0.1, 0.12, length), WOOD_LIGHT)


func _cow(at: Vector3) -> void:
    _box("Vaca - corpo", at + Vector3(0, 1.18, 0), Vector3(2.1, 1.13, 0.9), CREAM)
    _box("Vaca - cabeca", at + Vector3(1.2, 1.42, 0), Vector3(0.78, 0.85, 0.8), CREAM)
    _ball("Vaca - focinho", at + Vector3(1.62, 1.22, 0), Vector3(0.48, 0.36, 0.6), Color("#c48b84"))
    _box("Mancha", at + Vector3(-0.32, 1.57, 0.47), Vector3(0.8, 0.51, 0.025), Color("#353534"))
    for xx in [-0.72, 0.72]:
        for zz in [-0.3, 0.3]:
            _box("Pata da vaca", at + Vector3(xx, 0.34, zz), Vector3(0.25, 0.68, 0.23), Color("#d8c9aa"))
    for zz in [-0.33, 0.33]:
        _ball("Orelha", at + Vector3(1.18, 1.8, zz), Vector3(0.36, 0.17, 0.25), Color("#d8b9a0"))


func _chicken(at: Vector3) -> void:
    _ball("Galinha - corpo", at + Vector3(0, 0.38, 0), Vector3(0.68, 0.68, 0.61), CREAM)
    _ball("Galinha - cabeca", at + Vector3(0.26, 0.7, 0), Vector3(0.36, 0.36, 0.36), CREAM)
    _ball("Crista vermelha", at + Vector3(0.28, 0.91, 0), Vector3(0.16, 0.17, 0.14), Color("#d14a37"))
    _ball("Bico", at + Vector3(0.47, 0.65, 0), Vector3(0.19, 0.12, 0.15), Color("#e7b04c"))


func _animal_pen() -> void:
    _fence_x(10.3, 24.8, 11.3)
    _fence_x(10.3, 24.8, 24.0)
    _fence_z(10.3, 11.3, 24.0)
    _fence_z(24.8, 11.3, 24.0)
    _box("Abrigo do curral", Vector3(22.5, 1.55, 20.0), Vector3(3.6, 0.18, 4.4), WOOD_LIGHT)
    _box("Comedouro", Vector3(19.3, 0.45, 21.9), Vector3(3.0, 0.75, 1.1), WOOD)
    _cow(Vector3(15.6, 0, 17.9))
    _chicken(Vector3(19.8, 0, 15.2))
    _chicken(Vector3(20.9, 0, 16.0))


func _pond() -> void:
    var water := _cylinder("Lago de agua azul", Vector3(-24.0, 0.015, 15.0), 5.0, 0.08, Color("#72bfc6"))
    water.scale.z = 0.73
    for i in range(10):
        var angle := float(i) * TAU / 10.0
        _ball("Pedra da margem", Vector3(-24.0 + cos(angle) * 5.25, 0.13, 15.0 + sin(angle) * 3.9),
            Vector3(0.8, 0.26, 0.56), Color("#b4afa1"))


func _vehicle() -> void:
    var x := -25.0
    var z := -5.0
    _box("Carro azul - chassi", Vector3(x, 0.8, z), Vector3(3.2, 0.8, 1.7), Color("#8cc0cc"))
    _box("Carro azul - cabine", Vector3(x - 0.15, 1.47, z), Vector3(1.9, 0.64, 1.5), Color("#afdce2"))
    _box("Para-brisa", Vector3(x + 0.85, 1.48, z), Vector3(0.08, 0.47, 1.25), Color("#5d8d9d"))
    for xx in [-1.05, 1.05]:
        for zz in [-0.83, 0.83]:
            var wheel := _cylinder("Roda do carro", Vector3(x + xx, 0.43, z + zz), 0.43, 0.2, Color("#30363a"))
            wheel.rotation.x = PI / 2.0


func _tree(at: Vector3, variation: float) -> void:
    _cylinder("Tronco", at + Vector3(0, 1.4 * variation, 0), 0.26 * variation, 2.8 * variation, WOOD, 0.78)
    _ball("Copa baixa", at + Vector3(0, 3.0 * variation, 0), Vector3(2.7, 2.0, 2.6) * variation, LEAVES)
    _ball("Copa alta", at + Vector3(0.3, 3.88 * variation, 0.1), Vector3(2.15, 1.65, 2.2) * variation, Color("#65964f"))


func _trees() -> void:
    for i in range(65):
        var x := rng.randf_range(-47.0, 47.0)
        var z := rng.randf_range(-47.0, 47.0)
        if absf(x) < 29.0 and absf(z) < 28.0:
            continue
        if x < -18.0 and x > -31.0 and z > 8.0 and z < 22.0:
            continue
        _tree(Vector3(x, 0, z), rng.randf_range(0.74, 1.28))
    _tree(Vector3(-4.0, 0, -18.0), 1.24)
    _tree(Vector3(-29.0, 0, -17.5), 1.08)
    _tree(Vector3(-13.0, 0, 18.0), 0.97)


func _sky_details() -> void:
    for i in range(6):
        var x := -32.0 + float(i) * 12.0
        var z := -34.0 + float(i % 3) * 31.0
        _ball("Nuvem parte A", Vector3(x, 24.0 + float(i % 2) * 2.0, z), Vector3(6.0, 1.9, 2.7), Color("#f8f8ec"))
        _ball("Nuvem parte B", Vector3(x + 2.4, 24.9 + float(i % 2) * 2.0, z), Vector3(3.0, 2.4, 2.4), Color("#fffdf4"))
