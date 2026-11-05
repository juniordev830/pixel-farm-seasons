extends StaticBody3D
## Press E near the bed to rest until the next 06:00.
func _ready() -> void:
    position = Vector3(-3.6, 0.45, -16.2)
    var collider := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(2.4, 0.9, 1.8)
    collider.shape = shape
    add_child(collider)

func interact(actor: Node) -> void:
    if actor is Node3D and global_position.distance_to(actor.global_position) > 3.5:
        return
    var needs := get_node_or_null("../FarmerNeeds")
    if needs != null and needs.has_method("sleep_until_morning"):
        needs.sleep_until_morning()
