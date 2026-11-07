extends StaticBody3D
## Collision shells for farmhouse and barn. Doorway left open for future interior.
func wall(at: Vector3, size: Vector3) -> void:
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = size
    shape.shape = box
    shape.position = at
    add_child(shape)

func _ready() -> void:
    # House occupies x=-6..6, z=-17.5..-8.5. Front doorway x=-0.85..0.85.
    wall(Vector3(-3.425, 2.2, -8.5), Vector3(5.15, 4.4, 0.35))
    wall(Vector3(3.425, 2.2, -8.5), Vector3(5.15, 4.4, 0.35))
    wall(Vector3(0, 3.55, -8.5), Vector3(1.7, 1.7, 0.35))
    wall(Vector3(0, 2.2, -17.5), Vector3(12, 4.4, 0.35))
    wall(Vector3(-6, 2.2, -13), Vector3(0.35, 4.4, 9))
    wall(Vector3(6, 2.2, -13), Vector3(0.35, 4.4, 9))
    # Barn shell and doorway.
    wall(Vector3(22, 3.2, -24.5), Vector3(10, 6.4, 0.35))
    wall(Vector3(17, 3.2, -20), Vector3(0.35, 6.4, 9))
    wall(Vector3(27, 3.2, -20), Vector3(0.35, 6.4, 9))
    wall(Vector3(18.6, 3.2, -15.5), Vector3(3.2, 6.4, 0.35))
    wall(Vector3(25.4, 3.2, -15.5), Vector3(3.2, 6.4, 0.35))
    wall(Vector3(22, 5.3, -15.5), Vector3(3.6, 2.2, 0.35))
