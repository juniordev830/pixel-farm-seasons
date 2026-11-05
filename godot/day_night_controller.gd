extends Node
## Drives the 3D environment from the same in-game clock used by gameplay.
## This node is attached to Main and expects Environment/Sun and Environment/WorldEnvironment.
@export_range(0.0, 1440.0, 1.0) var initial_minute: float = 1020.0
@export_range(0.0, 120.0, 0.1) var game_minutes_per_real_second: float = 1.0
@export var paused: bool = false

var minute: float
var day_index: int = 0
@onready var sun: DirectionalLight3D = get_node_or_null("../Environment/Sun") as DirectionalLight3D
@onready var world: WorldEnvironment = get_node_or_null("../Environment/WorldEnvironment") as WorldEnvironment

func _ready() -> void:
    minute = initial_minute
    _update_lighting()

func _process(delta: float) -> void:
    if not paused:
        var total_minutes: float = minute + delta * game_minutes_per_real_second
        if total_minutes >= 1440.0:
            day_index += int(floor(total_minutes / 1440.0))
        minute = fposmod(total_minutes, 1440.0)
        _update_lighting()

func set_clock(hour: int, minute_part: int) -> void:
    minute = float(posmod(hour, 24) * 60 + posmod(minute_part, 60))
    _update_lighting()

func advance_to_next_morning() -> void:
    day_index += 1
    set_clock(6, 0)

func get_clock() -> String:
    return "%02d:%02d" % [int(minute / 60.0), int(minute) % 60]

func _update_lighting() -> void:
    # The procedural environment creates lighting nodes in its own _ready.
    # Depending on sibling initialization order they may not exist yet.
    if sun == null or not is_instance_valid(sun):
        sun = get_node_or_null("../Environment/Sun") as DirectionalLight3D
    if world == null or not is_instance_valid(world):
        world = get_node_or_null("../Environment/WorldEnvironment") as WorldEnvironment
    if sun == null or world == null or world.environment == null:
        return
    var hour := minute / 60.0
    var daylight: float
    var sky: Color
    if hour >= 5.0 and hour < 7.0:
        daylight = (hour - 5.0) / 2.0
        sky = Color("#131c42").lerp(Color("#ffaf73"), daylight)
    elif hour >= 7.0 and hour < 17.0:
        daylight = 1.0
        sky = Color("#6fbff4")
    elif hour >= 17.0 and hour < 19.0:
        daylight = (19.0 - hour) / 2.0
        sky = Color("#161a3d").lerp(Color("#ff935e"), daylight)
    else:
        daylight = 0.0
        sky = Color("#131a3a")
    sun.light_energy = 0.05 + 1.35 * daylight
    sun.rotation_degrees = Vector3(-12.0 - 55.0 * daylight, -35.0, 0.0)
    world.environment.background_color = sky
    world.environment.ambient_light_color = Color("#65749c").lerp(Color("#f3dfbe"), daylight)
    world.environment.ambient_light_energy = 0.22 + 0.65 * daylight
