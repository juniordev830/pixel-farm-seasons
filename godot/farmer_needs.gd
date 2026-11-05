extends Node
## Lightweight in-game survival state tied to DayNightController.
@export var max_energy: float = 100.0
@export var max_hunger: float = 100.0
@export var hunger_per_game_minute: float = 0.09
@export var idle_energy_loss_per_game_minute: float = 0.01
@export var walking_energy_loss_per_game_minute: float = 0.07
@export var sprint_energy_loss_per_game_minute: float = 0.24
var energy: float = 100.0
var hunger: float = 0.0
var hunger_comment_cooldown: float = 0.0
var message: String = ""
var message_remaining: float = 0.0

@onready var player: CharacterBody3D = $"../Player"
@onready var clock: Node = $"../DayNightController"

func _process(delta: float) -> void:
    if clock.paused:
        return
    var game_minutes: float = delta * clock.game_minutes_per_real_second
    var horizontal_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
    hunger = minf(max_hunger, hunger + hunger_per_game_minute * game_minutes)
    var cost: float = idle_energy_loss_per_game_minute
    if horizontal_speed > 5.7:
        cost = sprint_energy_loss_per_game_minute
    elif horizontal_speed > 0.2:
        cost = walking_energy_loss_per_game_minute
    energy = maxf(0.0, energy - cost * game_minutes)
    hunger_comment_cooldown = maxf(0.0, hunger_comment_cooldown - game_minutes)
    message_remaining = maxf(0.0, message_remaining - delta)
    if message_remaining <= 0.0:
        message = ""
    if hunger >= 65.0 and hunger_comment_cooldown <= 0.0:
        message = "Eita, preciso comer alguma coisa!"
        message_remaining = 5.0
        hunger_comment_cooldown = 120.0

func eat() -> void:
    hunger = maxf(0.0, hunger - 55.0)
    energy = minf(max_energy, energy + 15.0)
    message = "Agora sim, barriga cheia!"
    message_remaining = 4.0

func sleep_until_morning() -> void:
    clock.set_clock(6, 0)
    energy = max_energy
    hunger = minf(max_hunger, hunger + 20.0)
    message = "Bom dia! Hora de cuidar da fazenda."
    message_remaining = 5.0
