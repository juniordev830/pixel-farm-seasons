extends Node3D
## Open-plan prototype interior: living room, kitchen and bedroom.
## Decorative objects only; building_collision.gd owns the collision shell.
func piece(label: String, pos: Vector3, size: Vector3, tint: Color) -> void:
    var node := MeshInstance3D.new()
    node.name = label
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.roughness = 0.78
    node.material_override = mat
    add_child(node)

func _ready() -> void:
    # Farmhouse spans x -6..6 and z -17.5..-8.5.
    piece("WoodFloor", Vector3(0, 0.08, -13), Vector3(11.4, 0.16, 8.4), Color("#a6754c"))
    piece("LivingRoomRug", Vector3(-2.9, 0.18, -11.5), Vector3(3.0, 0.05, 2.5), Color("#b34d40"))
    piece("Sofa", Vector3(-4.6, 0.6, -11.8), Vector3(1.5, 0.8, 2.8), Color("#526d64"))
    piece("CoffeeTable", Vector3(-2.6, 0.45, -11.7), Vector3(1.4, 0.55, 0.85), Color("#68472e"))
    piece("KitchenCounter", Vector3(3.7, 0.55, -16.3), Vector3(3.2, 1.1, 0.75), Color("#d4b991"))
    piece("KitchenWorktop", Vector3(3.7, 1.13, -16.3), Vector3(3.4, 0.12, 0.95), Color("#c2c6bc"))
    piece("Fridge", Vector3(5.0, 1.0, -14.9), Vector3(1.0, 2.0, 0.9), Color("#d7e1db"))
    piece("DiningTable", Vector3(2.2, 0.7, -12.0), Vector3(2.0, 0.18, 1.2), Color("#76513b"))
    for x in [1.3, 3.1]:
        piece("DiningChair", Vector3(x, 0.45, -10.9), Vector3(0.65, 0.9, 0.65), Color("#946946"))
    piece("BedroomPartition", Vector3(-1.0, 1.6, -15.5), Vector3(0.18, 3.2, 3.3), Color("#e7d3ac"))
    piece("BedBase", Vector3(-3.6, 0.42, -16.2), Vector3(2.4, 0.6, 1.8), Color("#825b3e"))
    piece("Mattress", Vector3(-3.6, 0.77, -16.2), Vector3(2.25, 0.2, 1.7), Color("#e6e0d4"))
    piece("Pillow", Vector3(-4.25, 0.92, -16.2), Vector3(0.45, 0.14, 1.25), Color("#f6eee1"))
