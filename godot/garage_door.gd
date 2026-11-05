extends StaticBody3D
## Exterior-only garage gate: manual E control plus vehicle proximity.
## Prevents closing while the farmer or a vehicle is in the doorway.
@export var interaction_distance: float = 4.0
@export var vehicle_detection_distance: float = 7.0
@export var safety_distance: float = 2.2
@export var travel_height: float = 3.5
@export var opening_speed: float = 2.4
@export var close_delay: float = 3.0

var is_open: bool = false
var manual_override: bool = false
var closed_height: float = 1.65
var clear_timer: float = 0.0

func _ready() -> void:
    closed_height = position.y

func _near_door(node: Node3D, distance_limit: float) -> bool:
    var offset: Vector3 = to_local(node.global_position)
    # A rectangular safety zone follows the entire entrance, on both sides.
    return absf(offset.x) <= 3.25 and absf(offset.z) <= distance_limit

func _physics_process(delta: float) -> void:
    var vehicle_near: bool = false
    var passage_occupied: bool = false
    for vehicle in get_tree().get_nodes_in_group("vehicles"):
        if vehicle is Node3D:
            if vehicle.global_position.distance_to(global_position) <= vehicle_detection_distance:
                vehicle_near = true
            if _near_door(vehicle, safety_distance):
                passage_occupied = true
    var farmer := get_node_or_null("../../Player") as Node3D
    if farmer != null and _near_door(farmer, safety_distance):
        passage_occupied = true
    if vehicle_near or passage_occupied:
        clear_timer = close_delay
        is_open = true
    elif not manual_override:
        clear_timer = maxf(0.0, clear_timer - delta)
        if clear_timer <= 0.0:
            is_open = false
    var goal: float = closed_height + (travel_height if is_open else 0.0)
    position.y = move_toward(position.y, goal, opening_speed * delta)
    # The collision shape stays attached to the panel during motion.

func interact(actor: Node3D) -> void:
    if actor.global_position.distance_to(global_position) > interaction_distance:
        return
    if manual_override:
        manual_override = false
        clear_timer = close_delay
    else:
        manual_override = true
        is_open = true
    var needs := get_node_or_null("../../FarmerNeeds")
    if needs != null:
        needs.message = "Portão aberto manualmente!" if manual_override else "Portão em modo automático."
        needs.message_remaining = 4.0
