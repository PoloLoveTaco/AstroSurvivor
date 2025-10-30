extends CharacterBody2D

@export var speed: float = 600.0
@export var damage: float = 5.0

func _physics_process(_delta: float) -> void:
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
