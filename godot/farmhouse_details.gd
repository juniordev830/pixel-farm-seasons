extends Node3D
## Visual detail pass for the prototype farmhouse.
## Primitive geometry is temporary; use licensed production assets later.

func material(tint: Color, roughness: float = 0.8) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = tint
    result.roughness = roughness
    return result

func box_part(label: String, at: Vector3, size: Vector3, tint: Color) -> void:
    var node := MeshInstance3D.new()
    node.name = label
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = at
    node.material_override = material(tint)
    add_child(node)

func roof_slope(label: String, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    surface.set_uv(Vector2(0, 0))
    surface.add_vertex(a)
    surface.set_uv(Vector2(1, 0))
    surface.add_vertex(b)
    surface.set_uv(Vector2(1, 1))
    surface.add_vertex(c)
    surface.set_uv(Vector2(0, 0))
    surface.add_vertex(a)
    surface.set_uv(Vector2(1, 1))
    surface.add_vertex(c)
    surface.set_uv(Vector2(0, 1))
    surface.add_vertex(d)
    surface.generate_normals()
    var mesh := surface.commit()
    var node := MeshInstance3D.new()
    node.name = label
    node.mesh = mesh
    node.material_override = material(Color("#b94f31"), 0.93)
    node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
    add_child(node)

func lantern(at: Vector3) -> void:
    box_part("LanternFrame", at, Vector3(0.34, 0.48, 0.34), Color("#52382c"))
    box_part("LanternGlass", at, Vector3(0.25, 0.34, 0.25), Color("#ffd27d"))
    var light := OmniLight3D.new()
    light.position = at
    light.light_color = Color("#ffbd72")
    light.light_energy = 0.85
    light.omni_range = 5.0
    light.shadow_enabled = false
    add_child(light)

func _ready() -> void:
    # Main gabled roof above the existing farmhouse geometry.
    roof_slope("RoofFront", Vector3(-7, 4.75, -8), Vector3(0, 6.7, -8),
        Vector3(0, 6.7, -18), Vector3(-7, 4.75, -18))
    roof_slope("RoofBack", Vector3(0, 6.7, -8), Vector3(7, 4.75, -8),
        Vector3(7, 4.75, -18), Vector3(0, 6.7, -18))
    # Porch timber, railings and decorative planter boxes.
    for x in [-5.6, -3.5, 3.5, 5.6]:
        box_part("PorchRailingPost", Vector3(x, 0.95, -4.4),
            Vector3(0.18, 1.55, 0.18), Color("#765037"))
    for y in [0.75, 1.3]:
        box_part("PorchRailing", Vector3(-4.55, y, -4.4),
            Vector3(2.2, 0.12, 0.12), Color("#93643f"))
        box_part("PorchRailing", Vector3(4.55, y, -4.4),
            Vector3(2.2, 0.12, 0.12), Color("#93643f"))
    for x in [-4.8, 4.8]:
        box_part("Planter", Vector3(x, 0.6, -4.0),
            Vector3(0.9, 0.65, 0.8), Color("#bd704b"))
        box_part("PlantLeaves", Vector3(x, 1.12, -4.0),
            Vector3(0.7, 0.5, 0.65), Color("#35834c"))
    lantern(Vector3(-2.0, 3.1, -8.1))
    lantern(Vector3(2.0, 3.1, -8.1))
