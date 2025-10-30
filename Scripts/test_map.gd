extends Node2D

const CURSOR = preload("res://Assets/cursor.png")

@onready var stars := $"StarBackground" # ton ColorRect
var mat: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR)
	mat = stars.material as ShaderMaterial

func _process(_dt):
	var cam := get_viewport().get_camera_2d()
	if cam and mat:
		# envoie la position monde de la caméra au shader
		mat.set_shader_parameter("camera_offset", cam.global_position)
