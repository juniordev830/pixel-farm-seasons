extends StaticBody3D
## Matches the 110 x 110 ground mesh in farm_environment.gd.
func _ready() -> void:
    var collider := CollisionShape3D.new()
    var ground := BoxShape3D.new()
    ground.size = Vector3(110.0, 0.5, 110.0)
    collider.shape = ground
    collider.position = Vector3(0.0, -0.25, 0.0)
    add_child(collider)
