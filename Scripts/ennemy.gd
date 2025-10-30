extends CharacterBody2D

@export var speed = 200

var _target

func _ready() -> void:
	_target = get_tree().get_nodes_in_group("Player")[0]
	
func _physics_process(delta: float) -> void:
	if _target:
		var direction = (_target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
