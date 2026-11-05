extends Node3D
## Procedural farm dressing prototype. Attach to a Node3D in a Godot 4 scene.
## No external assets needed; replace primitive meshes with authored models later.

func _box(parent: Node3D, name: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = name
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.88
    node.material_override = mat
    parent.add_child(node)
    return node

func _ready() -> void:
    _box(self, "GrassGround", Vector3(0, -0.25, 0), Vector3(110, 0.5, 110), Color("#6eaa50"))
    # Hollow shell, with a doorway for future open/close door interactions.
    _box(self, "HouseBackWall", Vector3(0, 2.2, -17.5), Vector3(12, 4.4, 0.3), Color("#f3dfb7"))
    _box(self, "HouseLeftWall", Vector3(-6, 2.2, -13), Vector3(0.3, 4.4, 9), Color("#f3dfb7"))
    _box(self, "HouseRightWall", Vector3(6, 2.2, -13), Vector3(0.3, 4.4, 9), Color("#f3dfb7"))
    _box(self, "HouseFrontLeft", Vector3(-3.425, 2.2, -8.5), Vector3(5.15, 4.4, 0.3), Color("#f3dfb7"))
    _box(self, "HouseFrontRight", Vector3(3.425, 2.2, -8.5), Vector3(5.15, 4.4, 0.3), Color("#f3dfb7"))
    _box(self, "HouseFrontLintel", Vector3(0, 3.55, -8.5), Vector3(1.7, 1.7, 0.3), Color("#f3dfb7"))
    # The entrance stays open until an interactive door is implemented.
    for x in [-3.6, 3.6]:
        _box(self, "Window", Vector3(x, 2.7, -8.37), Vector3(1.8, 1.55, 0.16), Color("#92c9d9"))
        _box(self, "ShutterLeft", Vector3(x - 1.12, 2.7, -8.3), Vector3(0.35, 1.7, 0.18), Color("#326c89"))
        _box(self, "ShutterRight", Vector3(x + 1.12, 2.7, -8.3), Vector3(0.35, 1.7, 0.18), Color("#326c89"))
    _box(self, "Porch", Vector3(0, 0.16, -6.3), Vector3(13, 0.32, 4), Color("#b98756"))
    for x in [-5.8, 5.8]:
        _box(self, "PorchPost", Vector3(x, 1.85, -4.4), Vector3(0.32, 3.7, 0.32), Color("#6f452e"))
    _box(self, "Barn", Vector3(22, 3.2, -20), Vector3(10, 6.4, 9), Color("#a8403c"))
    _box(self, "BarnRoof", Vector3(22, 6.7, -20), Vector3(11, 0.7, 10), Color("#54363c"))
    _box(self, "BarnDoor", Vector3(22, 2.1, -15.4), Vector3(3.6, 4.2, 0.2), Color("#e9d7bd"))
    _box(self, "Path", Vector3(0, 0.015, 12), Vector3(4, 0.05, 32), Color("#c5a070"))
    # Pitched roof is built separately by farmhouse_details.gd.
    for row in range(5):
        for col in range(8):
            var x := -28.0 + col * 2.3
            var z := 7.0 + row * 2.8
            _box(self, "Soil", Vector3(x, 0.03, z), Vector3(1.8, 0.08, 2.1), Color("#70492f"))
            _box(self, "Crop", Vector3(x, 0.48, z), Vector3(0.45, 0.9, 0.45), Color("#3d863b"))
    var sun := DirectionalLight3D.new()
    sun.name = "Sun"
    sun.rotation_degrees = Vector3(-45, -35, 0)
    sun.light_energy = 1.2
    sun.shadow_enabled = true
    add_child(sun)
    var world := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("#8dc8ed")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("#e8d8bf")
    env.ambient_light_energy = 0.65
    world.environment = env
    add_child(world)
