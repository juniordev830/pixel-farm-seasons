extends StaticBody3D
## First interaction: inspect the workshop repair bench.
## Actual vehicle repairs and inventory will be implemented separately.
@export var interaction_distance: float = 3.6

func interact(actor: Node3D) -> void:
    if actor.global_position.distance_to(global_position) > interaction_distance:
        return
    var needs := get_node_or_null("../../FarmerNeeds")
    if needs == null:
        return
    needs.message = "Oficina pronta! Aqui vou consertar minhas ferramentas."
    needs.message_remaining = 6.0
