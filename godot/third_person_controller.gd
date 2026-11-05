extends CharacterBody3D
## GTA-style third-person follow camera: stays behind farmer in interiors and outdoors.
@export var walk_speed: float = 4.5
@export var sprint_speed: float = 7.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.0025
@export var acceleration: float = 18.0
@export var turn_speed: float = 9.0
@export var camera_follow_speed: float = 4.0
@onready var camera_pivot: Node3D = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var interaction_ray: RayCast3D = $CameraPivot/SpringArm3D/Camera3D/InteractionRay
@onready var body_visual: Node3D = $Body

func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    spring_arm.add_excluded_object(get_rid())

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
        camera_pivot.rotate_x(-event.relative.y * mouse_sensitivity)
        camera_pivot.rotation.x = clampf(camera_pivot.rotation.x, -0.95, 0.45)
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
        interaction_ray.force_raycast_update()
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
    var direction := camera_pivot.global_transform.basis * Vector3(movement.x, 0.0, movement.y)
    direction.y = 0.0
    direction = direction.normalized()
    var speed: float = sprint_speed if Input.is_key_pressed(KEY_SHIFT) else walk_speed
    velocity.x = move_toward(velocity.x, direction.x * speed, acceleration * delta)
    velocity.z = move_toward(velocity.z, direction.z * speed, acceleration * delta)
    if direction.length_squared() > 0.001:
        var target_yaw := atan2(-direction.x, -direction.z) - rotation.y
        body_visual.rotation.y = lerp_angle(body_visual.rotation.y, target_yaw, minf(delta * turn_speed, 1.0))
    move_and_slide()
    if body_visual.has_method("set_movement"):
        body_visual.set_movement(Vector2(velocity.x, velocity.z).length(), delta)
