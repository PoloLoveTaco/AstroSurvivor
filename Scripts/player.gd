extends CharacterBody2D

const BULLET = preload("res://Scenes/bullet.tscn")

@export_category("Current stats")
@export var health: float = 100
@export var speed: float = 400
@export var xp: float = 0
@export var seconds_between_attacks: float = 1
@export var level: int = 1

@export_category("Max stats")
@export var max_health: float = 100
@export var max_xp: float = 10

@onready var health_bar: ProgressBar = $CanvasLayer/UI/HealthBar
@onready var xp_bar: ProgressBar = $CanvasLayer/UI/XpBar
@onready var shooting_timer: Timer = $"Shooting Timer"
@onready var camera_2d: Camera2D = $Camera2D
@onready var level_label: Label = $CanvasLayer/UI/LevelLabel

@export var bullet_speed = 400

@export var nb_proj: int = 1
@export var cone_angle_deg: float = 30.0
@export var muzzle_offset: float = 12.0
@export var jitter_deg: float = 0.0


func _ready() -> void:
	health_bar.max_value = max_health
	health_bar.value = health
	update_life_bar()
	xp_bar.max_value = max_xp
	xp_bar.value = xp
	level_label.text = "Level " + str(level)
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

func shoot_cone_facing() -> void:
	var forward := Vector2.RIGHT.rotated(global_rotation)
	_shoot_cone_from_forward(forward)

func _shoot_cone_from_forward(forward: Vector2) -> void:
	var count = max(1, nb_proj)
	var half := deg_to_rad(clamp(cone_angle_deg, 0.0, 179.0)) * 0.5
	var spawn := global_position + forward * muzzle_offset

	if count == 1:
		_spawn_bullet(spawn, forward)
		return

	for i in range(count):
		var t := i / float(count - 1)
		var base_angle = lerp(-half, half, t) 
		var jitter := deg_to_rad(jitter_deg) * (randf() * 2.0 - 1.0)
		var dir := forward.rotated(base_angle + jitter)
		_spawn_bullet(spawn, dir)

func _spawn_bullet(spawn_pos: Vector2, dir: Vector2) -> void:
	var b = BULLET.instantiate()
	b.global_position = spawn_pos
	b.velocity = dir.normalized() * bullet_speed
	b.look_at(spawn_pos + dir * 10.0)
	get_tree().current_scene.add_child(b)

func _on_shooting_timer_timeout() -> void:
	shoot_cone_facing()
	shooting_timer.start()


#endregion

#region health management

func take_damage(amount: float):
	health -= amount
	health_bar.value = health
	camera_2d.start_shake(5, 0.2)
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
		level_label.text = "Level " + str(level)
		level = level + 1
		xp = xp - max_xp
		max_xp = max_xp + 10
	xp_bar.max_value = max_xp
	xp_bar.value = xp

func level_up():
	UpgradeManager.run()

#endregion


func _on_area_2d_area_entered(area: Area2D) -> void:
	var body = area.get_parent()
	if body.is_in_group("Collectable"):
		body.do(self)
