extends StaticBody3D
## Press E while looking at the door to open or close it.
@export var open_angle_degrees: float = -100.0
@export var animation_speed: float = 5.0
var is_open := false
var hinge: Node3D

func _ready() -> void:
    position = Vector3(-0.82, 0.0, -8.42)
    hinge = Node3D.new()
    hinge.name = "DoorHinge"
    add_child(hinge)
    var visual := MeshInstance3D.new()
    visual.name = "DoorPanel"
    var mesh := BoxMesh.new()
    mesh.size = Vector3(1.6, 2.5, 0.12)
    visual.mesh = mesh
    visual.position = Vector3(0.8, 1.25, 0.0)
    var paint := StandardMaterial3D.new()
    paint.albedo_color = Color("#765039")
    visual.material_override = paint
    hinge.add_child(visual)
    var handle := MeshInstance3D.new()
    handle.name = "Handle"
    var handle_mesh := SphereMesh.new()
    handle_mesh.radius = 0.085
    handle_mesh.height = 0.17
    handle.mesh = handle_mesh
    handle.position = Vector3(1.4, 1.15, 0.12)
    var brass := StandardMaterial3D.new()
    brass.albedo_color = Color("#d7ad55")
    brass.metallic = 0.7
    handle.material_override = brass
    hinge.add_child(handle)
    var collider := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(1.6, 2.5, 0.12)
    collider.shape = shape
    collider.position = Vector3(0.8, 1.25, 0)
    add_child(collider)

func interact(_actor: Node) -> void:
    is_open = not is_open
    # Door collision follows the hinge through a separately rotated collider.
    # Collision is disabled while open until an articulated physics door is implemented.
    $CollisionShape3D.set_deferred("disabled", is_open)

func _process(delta: float) -> void:
    var target := deg_to_rad(open_angle_degrees) if is_open else 0.0
    hinge.rotation.y = lerp_angle(hinge.rotation.y, target, minf(delta * animation_speed, 1.0))
