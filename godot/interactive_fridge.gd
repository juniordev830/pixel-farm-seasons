extends StaticBody3D
## Farmhouse refrigerator: look at it and press E to eat a meal.
func _ready() -> void:
    position = Vector3(5.0, 1.0, -14.9)
    var shape := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(1.0, 2.0, 0.9)
    shape.shape = box
    add_child(shape)

func interact(actor: Node) -> void:
    if actor is Node3D and global_position.distance_to(actor.global_position) > 3.5:
        return
    var needs := get_node_or_null("../FarmerNeeds")
    if needs != null and needs.has_method("eat"):
        needs.eat()
