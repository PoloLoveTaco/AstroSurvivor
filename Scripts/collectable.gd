extends Node2D
class_name Collectable

@export var acceleration: float = 1400.0
@export var max_speed: float = 900.0
@export var snap_distance: float = 20.0

var _target: Node2D = null
var _vel: Vector2 = Vector2.ZERO
var _gliding := false

func do(player: CharacterBody2D) -> void:
	_target = player
	_gliding = true
	set_process(true)
	for c in get_children():
		if c is CollisionShape2D or c is CollisionPolygon2D:
			c.set_deferred("disabled", true)

func _process(delta: float) -> void:
	if not _gliding or not is_instance_valid(_target):
		set_process(false)
		return

	var to := _target.global_position - global_position
	var dist := to.length()
	if dist <= snap_distance:
		_on_collected(_target)
		queue_free()
		return

	var dir = to / max(dist, 0.0001)
	_vel = _vel.move_toward(dir * max_speed, acceleration * delta)
	global_position += _vel * delta

func _on_collected(player: CharacterBody2D) -> void:
	do(player)
