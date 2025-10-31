extends Node2D

const CURSOR = preload("res://Assets/cursor.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(CURSOR, Input.CURSOR_ARROW, Vector2(16, 16))
