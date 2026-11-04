extends CharacterBody3D
## Pixel Farm Seasons: controle de fazendeiro em terceira pessoa (Godot 4).
## Estrutura: CharacterBody3D > CollisionShape3D, Visuals, CameraPivot > SpringArm3D > Camera3D.
## Input Map: move_left, move_right, move_forward, move_back, jump, sprint, crouch, toggle_camera.
@export var walk_speed: float = 4.0
@export var run_speed: float = 7.0
@export var crouch_speed: float = 2.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.0025
@export var gamepad_look_speed: float = 2.5
@export var min_pitch: float = -1.2
@export var max_pitch: float = 1.0
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var visuals: Node3D = $Visuals
var third_person: bool = true
var _original_arm_length: float

func _ready() -> void:
    _original_arm_length = camera_arm.spring_length
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera_pivot.rotation.x = clamp(camera_pivot.rotation.x - event.relative.y * mouse_sensitivity, min_pitch, max_pitch)
    if event.is_action_pressed("toggle_camera"):
        third_person = not third_person
        camera_arm.spring_length = _original_arm_length if third_person else 0.05
        visuals.visible = third_person

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = jump_velocity
    var stick := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var direction := (global_transform.basis * Vector3(stick.x, 0.0, stick.y)).normalized()
    var speed := crouch_speed if Input.is_action_pressed("crouch") else (run_speed if Input.is_action_pressed("sprint") else walk_speed)
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    move_and_slide()
