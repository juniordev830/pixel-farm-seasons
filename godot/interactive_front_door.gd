extends StaticBody3D
## Hinged physical door. The whole StaticBody3D rotates, including its collider.
@export var open_angle_degrees: float = -100.0
@export var animation_speed: float = 5.0
var is_open: bool = false

func _ready() -> void:
    position = Vector3(-0.82, 0.0, -8.42)
    var panel := MeshInstance3D.new()
    panel.name = "DoorPanel"
    var mesh := BoxMesh.new()
    mesh.size = Vector3(1.6, 2.5, 0.12)
    panel.mesh = mesh
    panel.position = Vector3(0.8, 1.25, 0)
    var wood := StandardMaterial3D.new()
    wood.albedo_color = Color("#765039")
    wood.roughness = 0.82
    panel.material_override = wood
    add_child(panel)

    var handle := MeshInstance3D.new()
    handle.name = "Handle"
    var handle_mesh := SphereMesh.new()
    handle_mesh.radius = 0.085
    handle_mesh.height = 0.17
    handle.mesh = handle_mesh
    handle.position = Vector3(1.42, 1.15, 0.13)
    var brass := StandardMaterial3D.new()
    brass.albedo_color = Color("#d7ad55")
    brass.metallic = 0.7
    handle.material_override = brass
    add_child(handle)

    var collider := CollisionShape3D.new()
    collider.name = "DoorCollision"
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.6, 2.5, 0.12)
    collider.shape = shape
    collider.position = Vector3(0.8, 1.25, 0)
    add_child(collider)

func interact(actor: Node) -> void:
    if actor is Node3D:
        if global_position.distance_to(actor.global_position) > 4.0:
            return
    is_open = not is_open

func _physics_process(delta: float) -> void:
    var target: float = deg_to_rad(open_angle_degrees) if is_open else 0.0
    rotation.y = lerp_angle(rotation.y, target, minf(delta * animation_speed, 1.0))
