extends CharacterBody2D

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

func _physics_process(_delta):
	get_input()
	move_and_slide()
