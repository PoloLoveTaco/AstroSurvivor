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
	update_life_bar()
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

#region shooting

func shoot():
	var b = BULLET.instantiate()
	b.global_position = global_position
	b.velocity = (get_global_mouse_position() - global_position).normalized() * b.speed
	b.look_at(get_global_mouse_position())
	get_tree().current_scene.add_child(b)


func _on_shooting_timer_timeout() -> void:
	shoot()
	shooting_timer.start()

#endregion

#region health management

func take_damage(amount: float):
	health -= amount
	health_bar.value = health
	update_life_bar()
	if health <= 0:
		queue_free()

func update_life_bar() -> void:
	var health_pourcent := health / max_health

	var fill := StyleBoxFlat.new()
	if health_pourcent > 0.50:
		fill.bg_color = Color(0.0, 0.941, 0.631)
	elif health_pourcent > 0.15:
		fill.bg_color = Color(1.0, 0.888, 0.317, 1.0)
	else:
		fill.bg_color = Color(1.0, 0.496, 0.451)
	health_bar.add_theme_stylebox_override("fill", fill)

#endregion

#region xp management

func get_xp(amount: float):
	xp = xp + amount
	if xp >= max_xp:
		level_up()
		xp = xp - max_xp
		max_xp = max_xp + 10

func level_up():
	UpgradeManager.run()
	print("wahouuuu lvl up")

#endregion


func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body.is_in_group("Collectable"):
		body.do(self)
