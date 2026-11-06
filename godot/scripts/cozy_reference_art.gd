extends Node3D
## Visual reference 2026-11-06: warm, colorful rural simulator.
## Adds only graphics to the actual playable Godot world.
## The screenshot concept is a visual target; this procedural art is not
## a claim to have reached that detailed modeling quality.

const WOOD := Color("#9e6641")
const WOOD_LITE := Color("#d6a56e")
const WOOD_DARK := Color("#634531")
const CREAM := Color("#f5e2bf")
const GOLD := Color("#f4cb82")
const STONE := Color("#b1aa90")
const PINK := Color("#e79ab1")
const PINK_LIGHT := Color("#f6c4ce")
const LEAF := Color("#58844a")
const LEAF_LIGHT := Color("#7ca763")
const BARN_WHITE := Color("#f8e7d2")
var rng := RandomNumberGenerator.new()


func _ready() -> void:
    rng.seed = 20261106
    call_deferred("_decorate")


func _mat(tint: Color, glow: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = tint
    m.roughness = 0.84
    if glow:
        m.emission_enabled = true
        m.emission = tint
        m.emission_energy_multiplier = 0.36
    return m


func _box(label: String, at: Vector3, size: Vector3, tint: Color) -> MeshInstance3D:
    var obj := MeshInstance3D.new()
    obj.name = label
    obj.set_meta("cozy_kind", label)
    var mesh := BoxMesh.new()
    mesh.size = size
    obj.mesh = mesh
    obj.position = at
    obj.material_override = _mat(tint)
    add_child(obj)
    return obj


func _ball(label: String, at: Vector3, size: Vector3, tint: Color) -> MeshInstance3D:
    var obj := MeshInstance3D.new()
    obj.name = label
    obj.set_meta("cozy_kind", label)
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 12
    mesh.rings = 7
    obj.mesh = mesh
    obj.position = at
    obj.scale = size
    obj.material_override = _mat(tint)
    add_child(obj)
    return obj


func _beam(label: String, from: Vector3, to: Vector3, radius: float, tint: Color) -> void:
    var direction := to - from
    if direction.length_squared() < 0.0001:
        return
    var beam := _box(label, (from + to) * 0.5, Vector3(radius, direction.length(), radius), tint)
    beam.quaternion = Quaternion(Vector3.UP, direction.normalized())


func _decorate() -> void:
    _shade_ground()
    _farmhouse_details()
    _garden_raised_beds()
    _barn_finish()
    _pergola()
    _farm_sign_and_lanterns()
    _flowering_trees()
    _distant_landscape()


func _shade_ground() -> void:
    var terrain := get_parent().get_node_or_null("Terreno principal") as MeshInstance3D
    if terrain != null:
        var grass := load("res://shaders/grass_stylized.gdshader") as Shader
        if grass != null:
            var material := ShaderMaterial.new()
            material.shader = grass
            terrain.material_override = material
    var earth := load("res://shaders/soil_stylized.gdshader") as Shader
    if earth != null:
        var soil := ShaderMaterial.new()
        soil.shader = earth
        for child in get_parent().get_children():
            if child is MeshInstance3D and String(child.get_meta("native_prop", child.name)).begins_with("Canteiro de terra"):
                (child as MeshInstance3D).material_override = soil
    var path_shader := load("res://shaders/dirt_path_stylized.gdshader") as Shader
    if path_shader != null:
        var dirt := ShaderMaterial.new()
        dirt.shader = path_shader
        for child in get_parent().get_children():
            if child is MeshInstance3D:
                var tag := String(child.get_meta("native_prop", child.name))
                if tag.begins_with("Estrada da fazenda") or tag.begins_with("Caminho ate a varanda"):
                    (child as MeshInstance3D).material_override = dirt


func _farmhouse_details() -> void:
    # Warm window-light behind shutters and handmade porch details.
    for floor_y in [1.65, 4.05]:
        for x in [-17.90, -12.10]:
            var window := _box("Janela iluminada", Vector3(x, floor_y, -10.08), Vector3(1.34, 1.15, 0.045), GOLD)
            window.material_override = _mat(GOLD, true)
            _box("Peitoril de madeira", Vector3(x, floor_y - 0.79, -10.00), Vector3(2.03, 0.13, 0.38), CREAM)
            for offset_x in [-0.42, 0.42]:
                _box("Veneziana quadro", Vector3(x + offset_x, floor_y, -9.99), Vector3(0.11, 1.32, 0.06), WOOD_DARK)
    for x in [-18.5, -16.8, -13.2, -11.5]:
        _box("Floreira", Vector3(x, 0.69, -7.56), Vector3(0.81, 0.31, 0.43), WOOD_DARK)
        for i in range(4):
            var offset := float(i) * 0.19 - 0.29
            _ball("Folhagem varanda", Vector3(x + offset, 0.92, -7.60), Vector3(0.39, 0.43, 0.32), LEAF)
            _ball("Flor varanda", Vector3(x + offset, 1.08, -7.50), Vector3(0.16, 0.16, 0.15), PINK if i % 2 == 0 else PINK_LIGHT)
    # Roof and balcony cross-beams create silhouettes that read as timber,
    # instead of bare cubes at a distance.
    for x in [-19.35, -16.3, -13.4, -10.65]:
        _beam("Caibro varanda", Vector3(x, 3.33, -8.95), Vector3(x, 3.33, -6.87), 0.15, WOOD)
    _box("Piso decorativo da sacada", Vector3(-15.0, 3.03, -8.0), Vector3(9.45, 0.17, 1.15), WOOD_LITE)
    _box("Faixa inferior da varanda", Vector3(-15.0, 0.24, -7.05), Vector3(10.1, 0.13, 0.13), WOOD_DARK)


func _garden_raised_beds() -> void:
    # 30 existing editable farming plots remain fully functional.
    # Add a wooden perimeter around each plot without new collisions.
    for row in range(5):
        for col in range(6):
            var x := 7.5 + float(col) * 1.58
            var z := 1.45 + float(row) * 1.85
            _box("Canteiro elevado bordo oeste", Vector3(x - 0.67, 0.27, z), Vector3(0.105, 0.40, 1.59), WOOD)
            _box("Canteiro elevado bordo leste", Vector3(x + 0.67, 0.27, z), Vector3(0.105, 0.40, 1.59), WOOD)
            _box("Canteiro elevado bordo norte", Vector3(x, 0.27, z - 0.81), Vector3(1.39, 0.40, 0.09), WOOD_LITE)
            _box("Canteiro elevado bordo sul", Vector3(x, 0.27, z + 0.81), Vector3(1.39, 0.40, 0.09), WOOD_LITE)
    # Crates and watering can next to the opening, not blocking the crops.
    _box("Caixote de legumes", Vector3(15.6, 0.38, 12.7), Vector3(1.32, 0.67, 0.75), WOOD_DARK)
    for i in range(5):
        _ball("Legumes colhidos", Vector3(15.0 + float(i) * 0.22, 0.72, 12.71),
            Vector3(0.21, 0.22, 0.22), Color("#dc8245") if i % 2 else Color("#72a44d"))
    _box("Regador corpo", Vector3(13.7, 0.45, 12.65), Vector3(0.50, 0.54, 0.38), Color("#7a9293"))
    _beam("Bico do regador", Vector3(13.95, 0.60, 12.65), Vector3(14.36, 0.73, 12.65), 0.07, Color("#899e9e"))


func _barn_finish() -> void:
    # Large X-pattern doors and white contrast imitate the approved art direction.
    _box("Celeiro moldura porta", Vector3(17.0, 1.82, -11.22), Vector3(4.05, 3.67, 0.12), BARN_WHITE)
    _box("Celeiro portas de madeira", Vector3(17.0, 1.82, -11.13), Vector3(3.65, 3.38, 0.11), Color("#a9503a"))
    for x in [16.13, 17.92]:
        _beam("Trava diagonal de madeira", Vector3(x - 0.74, 0.35, -11.04),
            Vector3(x + 0.74, 3.24, -11.04), 0.14, BARN_WHITE)
        _beam("Trava cruzada de madeira", Vector3(x - 0.74, 3.24, -11.02),
            Vector3(x + 0.74, 0.35, -11.02), 0.14, BARN_WHITE)
    _box("Travessa no topo celeiro", Vector3(17.0, 3.65, -11.09), Vector3(4.0, 0.15, 0.15), BARN_WHITE)
    for x in [11.7, 23.0]:
        _box("Caixa deposito celeiro", Vector3(x, 0.49, -9.8), Vector3(0.95, 0.92, 0.9), WOOD)
    # Silo hoops stop it appearing as a single smooth grey cylinder.
    for y in [1.45, 3.35, 5.25]:
        var ring := MeshInstance3D.new()
        ring.name = "Aro metalico do silo"
        var mesh := CylinderMesh.new()
        mesh.top_radius = 2.05
        mesh.bottom_radius = 2.05
        mesh.height = 0.085
        mesh.radial_segments = 18
        ring.mesh = mesh
        ring.position = Vector3(24, y, -15)
        ring.material_override = _mat(Color("#7b8a92"))
        add_child(ring)


func _pergola() -> void:
    # Hanging wisteria on the garage roof: stylized spheres for blossom groups.
    for x in [-28.85, -27.2, -25.1, -23.0, -21.2]:
        _box("Pergolado - ripas", Vector3(x, 3.18, -5.0), Vector3(0.17, 0.13, 7.75), WOOD_DARK)
        for z in [-7.5, -4.7, -2.2]:
            _ball("Trepadeira garagem", Vector3(x, 3.29, z),
                Vector3(1.20, 0.33, 0.97), LEAF)
            _ball("Cachos floridos garagem", Vector3(x, 2.91, z),
                Vector3(0.32, 0.65, 0.31), Color("#ab86b9"))
    _box("Prateleira oficina", Vector3(-28.3, 1.38, -7.75), Vector3(1.50, 0.10, 0.48), WOOD_LITE)
    for i in range(4):
        _box("Ferramentas na garagem", Vector3(-28.8 + float(i) * 0.33, 1.56, -7.73),
            Vector3(0.17, 0.22 + float(i % 2) * 0.15, 0.19), Color("#687c84"))


func _farm_sign_and_lanterns() -> void:
    # Sign is placed beside existing interactable mission board.
    _box("Totem fazenda madeira", Vector3(-7.0, 1.53, 8.20), Vector3(2.45, 1.1, 0.23), WOOD_DARK)
    _box("Totem fazenda interno", Vector3(-7.0, 1.53, 8.34), Vector3(2.27, 0.92, 0.055), WOOD_LITE)
    var label := Label3D.new()
    label.name = "Placa de boas-vindas"
    label.text = "PIXEL FARM\nSEASONS"
    label.font_size = 42
    label.pixel_size = 0.010
    label.modulate = Color("#553b28")
    label.outline_size = 0
    label.position = Vector3(-7.0, 1.54, 8.39)
    label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
    add_child(label)
    for x in [-8.3, -5.75]:
        var glow := _box("Lampiao de entrada", Vector3(x, 1.33, 9.20), Vector3(0.30, 0.41, 0.29), GOLD)
        glow.material_override = _mat(GOLD, true)
        _box("Lampiao poste", Vector3(x, 0.68, 9.20), Vector3(0.11, 1.36, 0.11), WOOD_DARK)


func _flowering_trees() -> void:
    # Spring trees create the pink flowering backdrop seen in the design reference.
    for center in [Vector3(-7.0, 0, -28), Vector3(4.0, 0, -27), Vector3(34, 0, -28)]:
        var trunk := _box("Cerejeira tronco", center + Vector3(0, 1.72, 0),
            Vector3(0.36, 3.44, 0.36), WOOD_DARK)
        trunk.rotation.y = rng.randf_range(-0.25, 0.25)
        for i in range(7):
            var angle := float(i) * TAU / 7.0
            var crown: Vector3 = center + Vector3(cos(angle) * 1.45, rng.randf_range(3.65, 5.20), sin(angle) * 1.28)
            _ball("Cerejeira copa florida", crown, Vector3(2.65, 2.55, 2.55),
                PINK if i % 3 == 0 else PINK_LIGHT)
        _ball("Cerejeira copa central", center + Vector3(0, 5.0, 0),
            Vector3(3.5, 3.25, 3.5), PINK_LIGHT)


func _distant_landscape() -> void:
    # Very low silhouettes on the horizon, far outside the playable terrain.
    for hill in [
        Vector4(-96.0, -96.0, 105.0, 20.0),
        Vector4(-14.0, -108.0, 119.0, 25.0),
        Vector4(87.0, -94.0, 112.0, 21.0)
    ]:
        var rise := _ball("Colinas distantes", Vector3(hill.x, -7.5, hill.y),
            Vector3(hill.z, hill.w, 44.0), Color("#77908a"))
        rise.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
