extends Node3D
## Fazendeiro estilizado 3D: corpo, roupas, botas, chapeu de palha e mochila.
## Arte provisoria de malhas primitivas para usar ate receber um personagem GLB rigado.

const SKIN := Color("#c58e60")
const CHECKER_RED := Color("#9b493f")
const CHECKER_RED_LIGHT := Color("#c36b5b")
const JEANS := Color("#365c79")
const HAT := Color("#d8bc79")
const BOOTS := Color("#59412f")
const ANIMATED_FARMER = preload("res://assets/kenney/characters/character-male-a.glb")

var farmer: CharacterBody3D
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var gait_time := 0.0
var imported_model: Node3D
var animation_player: AnimationPlayer
var current_anim := ""


func _ready() -> void:
    farmer = get_parent().get_parent() as CharacterBody3D
    _build_character()
    _install_animated_farmer()
    var old_body := get_parent().get_node_or_null("Body") as Node3D
    var old_head := get_parent().get_node_or_null("Head") as Node3D
    if old_body != null:
        old_body.visible = false
    if old_head != null:
        old_head.visible = false


func _find_animation_player(node: Node) -> AnimationPlayer:
    if node is AnimationPlayer:
        return node as AnimationPlayer
    for child in node.get_children():
        var match_player := _find_animation_player(child)
        if match_player != null:
            return match_player
    return null


func _choose_animation(action: String) -> String:
    if animation_player == null:
        return ""
    if animation_player.has_animation(action):
        return action
    for candidate in animation_player.get_animation_list():
        var test := String(candidate)
        if test.ends_with("/" + action) or test.ends_with(":" + action):
            return test
    return ""


func _install_animated_farmer() -> void:
    if ANIMATED_FARMER == null:
        push_warning("Farmer model not available; leaving placeholder visible")
        return
    var rig := ANIMATED_FARMER.instantiate() as Node3D
    if rig == null:
        return
    # Hide primitive humanoid but keep those nodes for backwards-compatible
    # tests; only the new rigged model is rendered during gameplay.
    for item in get_children():
        if item is MeshInstance3D or item == left_leg or item == right_leg or item == left_arm or item == right_arm:
            (item as Node3D).visible = false
    imported_model = rig
    imported_model.name = "FazendeiroAnimado"
    imported_model.position = Vector3(0, -1.08, 0)
    imported_model.scale = Vector3.ONE * 2.68
    imported_model.rotation.y = PI
    add_child(imported_model)
    animation_player = _find_animation_player(imported_model)
    current_anim = ""
    _play_farm_animation("idle")
    # Hat, backpack and denim details are preserved as recognizable farm gear.
    _cylinder(self, Vector3(0, 0.78, 0), 0.52, 0.075, HAT)
    _cylinder(self, Vector3(0, 0.89, 0), 0.30, 0.24, Color("#e4c98a"))
    _cylinder(self, Vector3(0, 0.85, 0), 0.312, 0.05, Color("#75563b"))
    _box(self, Vector3(0, -0.11, 0.32), Vector3(0.56, 0.66, 0.26), Color("#7d5c43"))
    _box(self, Vector3(0, -0.32, 0.48), Vector3(0.48, 0.23, 0.055), Color("#a58154"))


func _play_farm_animation(name: String) -> void:
    var actual := _choose_animation(name)
    if animation_player == null or actual.is_empty() or current_anim == actual:
        return
    current_anim = actual
    animation_player.play(actual, 0.20)


func _mat(color: Color) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.roughness = 0.90
    return mat


func _box(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = at
    node.material_override = _mat(color)
    parent.add_child(node)


func _cylinder(parent: Node3D, at: Vector3, radius: float, height: float, color: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = 16
    node.mesh = mesh
    node.position = at
    node.material_override = _mat(color)
    parent.add_child(node)


func _ball(parent: Node3D, at: Vector3, size: Vector3, color: Color) -> void:
    var node := MeshInstance3D.new()
    var mesh := SphereMesh.new()
    mesh.radius = 0.5
    mesh.height = 1.0
    mesh.radial_segments = 12
    mesh.rings = 7
    node.mesh = mesh
    node.position = at
    node.scale = size
    node.material_override = _mat(color)
    parent.add_child(node)


func _build_character() -> void:
    # Frente do personagem: -Z, coerente com a direcao inicial da camera.
    _box(self, Vector3(0, -0.1, 0), Vector3(0.76, 0.74, 0.40), CHECKER_RED)
    _box(self, Vector3(0, -0.48, 0), Vector3(0.73, 0.24, 0.42), JEANS)
    _box(self, Vector3(0, 0.42, 0), Vector3(0.20, 0.27, 0.21), SKIN)
    _ball(self, Vector3(0, 0.68, 0), Vector3(0.43, 0.51, 0.42), SKIN)

    # Camisa xadrez simples com padrao geometricamente legivel.
    for row in range(3):
        for col in range(4):
            _box(self, Vector3(-0.27 + float(col) * 0.18, -0.37 + float(row) * 0.23, -0.21),
                Vector3(0.10, 0.12, 0.025),
                CHECKER_RED_LIGHT if (row + col) % 2 == 0 else CHECKER_RED)

    # Colete/alças de mochila e mochila nas costas.
    _box(self, Vector3(0, -0.08, 0.35), Vector3(0.55, 0.7, 0.31), Color("#775134"))
    _box(self, Vector3(0, -0.24, 0.54), Vector3(0.46, 0.31, 0.08), Color("#987147"))
    for x in [-0.27, 0.27]:
        _box(self, Vector3(x, -0.06, -0.23), Vector3(0.085, 0.61, 0.07), Color("#997246"))

    # Chapeu: aba grande, copa e faixa escura.
    _cylinder(self, Vector3(0, 0.94, 0), 0.53, 0.08, HAT)
    _cylinder(self, Vector3(0, 1.06, 0), 0.31, 0.30, Color("#e5ca8b"))
    _cylinder(self, Vector3(0, 0.99, 0), 0.323, 0.055, Color("#775235"))

    left_leg = Node3D.new()
    left_leg.name = "PernaEsquerda"
    left_leg.position = Vector3(-0.20, -0.57, 0)
    add_child(left_leg)
    _box(left_leg, Vector3(0, -0.26, 0), Vector3(0.29, 0.55, 0.31), JEANS)
    _box(left_leg, Vector3(0, -0.61, -0.08), Vector3(0.32, 0.28, 0.45), BOOTS)

    right_leg = Node3D.new()
    right_leg.name = "PernaDireita"
    right_leg.position = Vector3(0.20, -0.57, 0)
    add_child(right_leg)
    _box(right_leg, Vector3(0, -0.26, 0), Vector3(0.29, 0.55, 0.31), JEANS)
    _box(right_leg, Vector3(0, -0.61, -0.08), Vector3(0.32, 0.28, 0.45), BOOTS)

    left_arm = Node3D.new()
    left_arm.name = "BracoEsquerdo"
    left_arm.position = Vector3(-0.48, 0.16, 0)
    add_child(left_arm)
    _box(left_arm, Vector3(-0.02, -0.25, 0), Vector3(0.24, 0.46, 0.28), CHECKER_RED)
    _box(left_arm, Vector3(-0.02, -0.55, 0), Vector3(0.21, 0.17, 0.20), SKIN)

    right_arm = Node3D.new()
    right_arm.name = "BracoDireito"
    right_arm.position = Vector3(0.48, 0.16, 0)
    add_child(right_arm)
    _box(right_arm, Vector3(0.02, -0.25, 0), Vector3(0.24, 0.46, 0.28), CHECKER_RED)
    _box(right_arm, Vector3(0.02, -0.55, 0), Vector3(0.21, 0.17, 0.20), SKIN)


func _process(delta: float) -> void:
    if farmer == null:
        return
    var horizontal_speed := Vector2(farmer.velocity.x, farmer.velocity.z).length()
    if imported_model != null:
        var wanted := "idle"
        if not farmer.is_on_floor():
            wanted = "jump"
        elif horizontal_speed > 5.15:
            wanted = "sprint"
        elif horizontal_speed > 0.15:
            wanted = "walk"
        elif Input.is_action_pressed("crouch"):
            wanted = "crouch"
        _play_farm_animation(wanted)
    var moving := horizontal_speed > 0.15 and farmer.is_on_floor()
    if moving:
        gait_time += delta * (9.0 if horizontal_speed < 5.0 else 13.0)
    var swing := sin(gait_time) * 0.38 if moving else 0.0
    var smoothing := minf(1.0, delta * 10.0)
    left_leg.rotation.x = lerpf(left_leg.rotation.x, swing, smoothing)
    right_leg.rotation.x = lerpf(right_leg.rotation.x, -swing, smoothing)
    left_arm.rotation.x = lerpf(left_arm.rotation.x, -swing * 0.7, smoothing)
    right_arm.rotation.x = lerpf(right_arm.rotation.x, swing * 0.7, smoothing)
