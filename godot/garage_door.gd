extends StaticBody3D
## Garage gate: manual E interaction and automatic vehicle proximity.
@export var interaction_distance: float = 4.0
@export var vehicle_detection_distance: float = 7.0
@export var travel_height: float = 3.5
@export var opening_speed: float = 2.4
@export var close_delay: float = 3.0
var is_open: bool = false
var manual_override: bool = false
var closed_height: float = 1.65
var clear_timer: float = 0.0
@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
    closed_height = position.y

func _physics_process(delta: float) -> void:
    var vehicle_near: bool = false
    for vehicle in get_tree().get_nodes_in_group("vehicles"):
        if vehicle is Node3D and vehicle.global_position.distance_to(global_position) <= vehicle_detection_distance:
            vehicle_near = true
            break
    if vehicle_near:
        clear_timer = close_delay
        is_open = true
    elif not manual_override:
        clear_timer = maxf(0.0, clear_timer - delta)
        if clear_timer <= 0.0:
            is_open = false
    var goal: float = closed_height + (travel_height if is_open else 0.0)
    position.y = move_toward(position.y, goal, opening_speed * delta)
    # Mesh and physical collider move together; never disable collision.

func interact(actor: Node3D) -> void:
    if actor.global_position.distance_to(global_position) > interaction_distance:
        return
    manual_override = not manual_override if is_open else true
    is_open = manual_override
    var needs := get_node_or_null("../../FarmerNeeds")
    if needs != null:
        needs.message = "Portão da garagem aberto!" if is_open else "Portão em modo automático."
        needs.message_remaining = 4.0
