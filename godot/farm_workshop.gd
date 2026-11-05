extends Node3D
## Open-front workshop beside the farmhouse. Prototype meshes are replaceable.
## Origin is at (13, 0, 12), away from the house entrance and crop field.
const WOOD := Color("#91623f")
const DARK_WOOD := Color("#533a2c")
const METAL := Color("#66727a")
const ROOF := Color("#805049")

func block(label: String, pos: Vector3, size: Vector3, tint: Color, solid: bool = false) -> void:
    var mesh_node := MeshInstance3D.new()
    mesh_node.name = label
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_node.mesh = mesh
    mesh_node.position = pos
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.roughness = 0.8
    mesh_node.material_override = material
    add_child(mesh_node)
    if solid:
        var collider := StaticBody3D.new()
        collider.name = label + "Collision"
        var shape := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = size
        shape.shape = box
        collider.position = pos
        collider.add_child(shape)
        add_child(collider)

func _ready() -> void:
    # Open front faces +Z, so the player can walk directly inside.
    block("ConcreteFloor", Vector3(0, 0.10, 0), Vector3(8.5, 0.20, 7.5), Color("#9a968d"), true)
    for x in [-4.0, 4.0]:
        for z in [-3.35, 3.35]:
            block("TimberPost", Vector3(x, 1.8, z), Vector3(0.32, 3.6, 0.32), DARK_WOOD, true)
    block("BackWall", Vector3(0, 1.65, -3.5), Vector3(8.3, 3.3, 0.22), WOOD, true)
    block("LeftWall", Vector3(-4.15, 1.4, 0), Vector3(0.22, 2.8, 7.0), WOOD, true)
    block("RightWall", Vector3(4.15, 1.4, 0), Vector3(0.22, 2.8, 7.0), WOOD, true)
    block("MetalRoof", Vector3(0, 3.8, 0), Vector3(9.0, 0.28, 8.0), ROOF, true)
    block("RoofFrontTrim", Vector3(0, 3.55, 3.8), Vector3(9.0, 0.35, 0.3), DARK_WOOD)
    # Workbench near the rear wall, leaving the entrance unobstructed.
    block("BenchTop", Vector3(-1.9, 1.02, -2.5), Vector3(3.1, 0.18, 0.85), DARK_WOOD)
    for x in [-3.15, -0.65]:
        block("BenchLeg", Vector3(x, 0.55, -2.5), Vector3(0.17, 0.9, 0.65), WOOD)
    block("ToolPegboard", Vector3(-1.9, 2.0, -3.34), Vector3(3.0, 1.35, 0.12), DARK_WOOD)
    for x in [-2.8, -2.15, -1.5, -0.85]:
        block("HangingTool", Vector3(x, 2.05, -3.22), Vector3(0.10, 0.7, 0.13), METAL)
    block("ToolChest", Vector3(2.45, 0.65, -2.55), Vector3(1.5, 1.3, 0.9), Color("#b54736"), true)
    for y in [0.45, 0.8, 1.15]:
        block("DrawerHandle", Vector3(2.45, y, -2.07), Vector3(0.65, 0.06, 0.06), METAL)
    block("StorageShelf", Vector3(3.35, 1.65, 0.8), Vector3(0.65, 0.13, 2.4), WOOD)
    block("OilCan", Vector3(3.3, 1.95, 0.2), Vector3(0.4, 0.5, 0.4), Color("#d2a73d"))
    # Repair station receives interaction ray and handles its own distance check.
    var station := StaticBody3D.new()
    station.name = "RepairWorkbench"
    station.set_script(load("res://workshop_workbench.gd"))
    station.position = Vector3(-1.9, 1.1, -2.5)
    var station_shape := CollisionShape3D.new()
    var station_box := BoxShape3D.new()
    station_box.size = Vector3(3.1, 0.65, 1.0)
    station_shape.shape = station_box
    station.add_child(station_shape)
    add_child(station)
