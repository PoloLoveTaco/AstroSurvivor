extends CharacterBody2D

@export var speed: float = 600.0

func _physics_process(_delta: float) -> void:
	move_and_slide()


func _on_area_2d_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Enemy"):
		self.queue_free()
