extends CharacterBody2D

@export var speed: float = 600.0

func _physics_process(_delta: float) -> void:
	move_and_slide()
