extends StaticBody3D
## Sliding garage door. Interact with E while standing close.
@export var interaction_distance: float = 4.0
@export var travel_height: float = 3.2
@export var opening_speed: float = 2.4
var is_open: bool = false
var closed_height: float = 1.65
@onready var panel: MeshInstance3D = $Panel
@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
    closed_height = position.y

func _process(delta: float) -> void:
    var goal: float = closed_height + (travel_height if is_open else 0.0)
    position.y = move_toward(position.y, goal, opening_speed * delta)
    # Keep the doorway clear while the panel is raised.
    collision.disabled = position.y > closed_height + 2.6

func interact(actor: Node3D) -> void:
    if actor.global_position.distance_to(global_position) > interaction_distance:
        return
    is_open = not is_open
    var needs := get_node_or_null("../../FarmerNeeds")
    if needs != null:
        needs.message = "Portão da garagem aberto!" if is_open else "Fechando o portão da garagem."
        needs.message_remaining = 4.0
