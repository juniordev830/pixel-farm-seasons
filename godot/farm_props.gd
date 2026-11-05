extends Node3D
## Decorative procedural farm props. Attach to an empty Node3D.
## These are low-poly placeholders; they require no downloaded assets.

@export var tree_count: int = 26
@export var fence_sections: int = 22

func make_box(pos: Vector3, size: Vector3, tint: Color) -> void:
    var m := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    m.mesh = box
    m.position = pos
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    m.material_override = material
    add_child(m)

func make_sphere(pos: Vector3, radius: float, tint: Color) -> void:
    var m := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = radius
    sphere.height = radius * 2.0
    m.mesh = sphere
    m.position = pos
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.roughness = 1.0
    m.material_override = material
    add_child(m)

func _ready() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 8302026
    for i in range(tree_count):
        var x := rng.randf_range(-49.0, 49.0)
        var z := rng.randf_range(-49.0, 49.0)
        # Keep the central house, path, barn and crop areas unobstructed.
        if absf(x) < 34.0 and absf(z) < 32.0:
            continue
        var height := rng.randf_range(3.5, 6.0)
        make_box(Vector3(x, height / 2.0, z), Vector3(0.65, height, 0.65), Color("#765238"))
        make_sphere(Vector3(x, height + 1.0, z), rng.randf_range(2.0, 3.0), Color("#3c854b"))
    for i in range(fence_sections):
        var z := -39.0 + i * 3.4
        make_box(Vector3(35, 0.9, z), Vector3(0.25, 1.8, 0.25), Color("#865b3b"))
        if i < fence_sections - 1:
            make_box(Vector3(35, 1.25, z + 1.7), Vector3(0.16, 0.15, 3.4), Color("#b38756"))
            make_box(Vector3(35, 0.55, z + 1.7), Vector3(0.16, 0.15, 3.4), Color("#b38756"))
    # Hay bales near the barn.
    for i in range(5):
        make_box(Vector3(17 + (i % 3) * 1.5, 0.55, -10 + (i / 3) * 1.6),
            Vector3(1.25, 1.1, 1.2), Color("#d8b45e"))
