extends CharacterBody2D

const BULLET = preload("res://Scenes/bullet.tscn")

@export_category("Current stats")
@export var health: float = 100
@export var speed: float = 400
@export var xp: float = 0
@export var seconds_between_attacks: float = 1

@export_category("Max stats")
@export var max_health: float = 100
@export var max_xp: float = 10

@onready var health_bar: ProgressBar = $CanvasLayer/UI/HealthBar
@onready var xp_bar: ProgressBar = $CanvasLayer/UI/XpBar
@onready var shooting_timer: Timer = $"Shooting Timer"

func _ready() -> void:
	health_bar.max_value = max_health
	health_bar.value = health
	xp_bar.max_value = max_xp
	xp_bar.value = xp
	shooting_timer.wait_time = seconds_between_attacks
	shooting_timer.start()

func get_input():
	look_at(get_global_mouse_position())
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(_delta):
	get_input()
	move_and_slide()

func shoot():
	var b = BULLET.instantiate()
	b.global_position = global_position
	b.velocity = (get_global_mouse_position() - global_position).normalized() * b.speed
	b.look_at(get_global_mouse_position())
	get_tree().current_scene.add_child(b)

func _on_shooting_timer_timeout() -> void:
	shoot()
	shooting_timer.start()

func take_damage(amount: float):
	health -= amount
	health_bar.value = health
	if health <= 0:
		queue_free()
