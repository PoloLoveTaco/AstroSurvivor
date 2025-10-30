extends CharacterBody2D

const BULLET = preload("uid://7vwsap1y2sw5")

@export_category("Current stats")
@export var health: float = 100
@export var speed: float = 400
@export var xp: float = 0

@export_category("Max stats")
@export var max_health: float = 100
@export var max_xp: float = 10

@onready var progress_bar: ProgressBar = $CanvasLayer/UI/ProgressBar

func _ready() -> void:
	progress_bar.value = health / max_health * 100

func get_input():
	look_at(get_global_mouse_position())
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	
	if Input.is_action_just_pressed("shoot"):
		shoot()

func _physics_process(_delta):
	get_input()
	move_and_slide()

func shoot():
	var b = BULLET.instantiate()
	b.global_position = global_position
	b.velocity = (get_global_mouse_position() - global_position).normalized() * b.speed
	get_tree().current_scene.add_child(b)
