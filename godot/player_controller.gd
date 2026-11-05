extends CharacterBody3D
## Prototype third-person movement. Attach to a CharacterBody3D with CollisionShape3D.
@export var walk_speed: float = 4.0
@export var sprint_speed: float = 7.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.002
@onready var pivot: Node3D = $CameraPivot

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        pivot.rotation.x = clamp(pivot.rotation.x, -1.1, 0.5)
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = jump_velocity
    var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var direction := (transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
    var speed := sprint_speed if Input.is_key_pressed(KEY_SHIFT) else walk_speed
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    move_and_slide()
