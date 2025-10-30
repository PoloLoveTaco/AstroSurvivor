extends Node2D

const CURSOR = preload("res://Assets/cursor.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR)
