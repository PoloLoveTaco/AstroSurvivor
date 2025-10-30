extends RigidBody2D

@export_category("Current stats")
@export var health: float = 10
@export var speed: float = 100
@export var damage: float = 5

@export_category("Max stats")
@export var max_health: float = 10

var _target

func _ready() -> void:
	_target = get_tree().get_nodes_in_group("Player")[0]
	
func _physics_process(delta: float) -> void:
	if _target:
		
		look_at(_target.global_position)
		position = position.move_toward(_target.global_position, speed * delta)
