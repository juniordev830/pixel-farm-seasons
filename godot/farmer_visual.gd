extends Node3D
## Procedural farmer placeholder with simple walk-cycle motion.
## Replace with a rigged GLB character and AnimationTree in production.
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D
var walk_phase: float = 0.0

func part(parent: Node3D, name: String, at: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.name = name
    mesh_instance.position = at
    var mesh := BoxMesh.new()
    mesh.size = size
    mesh_instance.mesh = mesh
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.85
    mesh_instance.material_override = mat
    parent.add_child(mesh_instance)
    return mesh_instance

func limb(name: String, pivot: Vector3, size: Vector3, color: Color) -> Node3D:
    var node := Node3D.new()
    node.name = name
    node.position = pivot
    add_child(node)
    part(node, "Mesh", Vector3(0, -size.y * 0.5, 0), size, color)
    return node

func _ready() -> void:
    part(self, "Torso", Vector3(0, 0.12, 0), Vector3(0.66, 0.76, 0.38), Color("#3d7c92"))
    part(self, "Neck", Vector3(0, 0.58, 0), Vector3(0.19, 0.2, 0.19), Color("#c78f65"))
    part(self, "Head", Vector3(0, 0.77, 0), Vector3(0.39, 0.43, 0.37), Color("#c78f65"))
    part(self, "HatBrim", Vector3(0, 1.02, 0), Vector3(0.75, 0.09, 0.65), Color("#987144"))
    part(self, "HatCrown", Vector3(0, 1.18, 0), Vector3(0.46, 0.28, 0.45), Color("#b18a52"))
    left_arm = limb("LeftArm", Vector3(-0.43, 0.45, 0), Vector3(0.23, 0.72, 0.25), Color("#3d7c92"))
    right_arm = limb("RightArm", Vector3(0.43, 0.45, 0), Vector3(0.23, 0.72, 0.25), Color("#3d7c92"))
    left_leg = limb("LeftLeg", Vector3(-0.18, -0.28, 0), Vector3(0.26, 0.65, 0.3), Color("#4e5e80"))
    right_leg = limb("RightLeg", Vector3(0.18, -0.28, 0), Vector3(0.26, 0.65, 0.3), Color("#4e5e80"))

func set_movement(speed: float, delta: float) -> void:
    if speed > 0.2:
        walk_phase += delta * (9.0 if speed < 6.0 else 13.0)
    var amplitude: float = 0.0 if speed <= 0.2 else 0.55
    var swing: float = sin(walk_phase) * amplitude
    left_arm.rotation.x = lerpf(left_arm.rotation.x, swing, minf(delta * 10.0, 1.0))
    right_arm.rotation.x = lerpf(right_arm.rotation.x, -swing, minf(delta * 10.0, 1.0))
    left_leg.rotation.x = lerpf(left_leg.rotation.x, -swing, minf(delta * 10.0, 1.0))
    right_leg.rotation.x = lerpf(right_leg.rotation.x, swing, minf(delta * 10.0, 1.0))
