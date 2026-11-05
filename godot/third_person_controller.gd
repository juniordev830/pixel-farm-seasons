extends CharacterBody3D
## Third-person controller: WASD/arrows, Shift sprint, Space jump, mouse camera.
@export var walk_speed := 4.5
@export var sprint_speed := 7.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.0025
@onready var camera_pivot: Node3D = $CameraPivot
@onready var interaction_ray: RayCast3D = $CameraPivot/Camera3D/InteractionRay

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * mouse_sensitivity)
        camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -1.1, 0.5)
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
        if interaction_ray.is_colliding():
            var target := interaction_ray.get_collider()
            if target != null and target.has_method("interact"):
                target.interact(self)

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity += get_gravity() * delta
    if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
        velocity.y = jump_velocity
    var movement := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var direction := (transform.basis * Vector3(movement.x, 0.0, movement.y)).normalized()
    var speed := sprint_speed if Input.is_key_pressed(KEY_SHIFT) else walk_speed
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
    move_and_slide()
