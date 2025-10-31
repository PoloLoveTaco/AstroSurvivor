extends RigidBody2D
class_name Enemy

@export_category("Current stats")
@export var health: float = 10
@export var speed: float = 100
@export var damage: float = 5
@export var xp_value: float = 10

@export_category("Max stats")
@export var max_health: float = 10

@export_category("Others")
@export var damage_popup_scene: PackedScene
@export var xp_scene: PackedScene

var _target
var _dead := false

func _ready() -> void:
	_target = get_tree().get_nodes_in_group("Player")[0]
	
func _physics_process(delta: float) -> void:
	if _target:
		look_at(_target.global_position)
		position = position.move_toward(_target.global_position, speed * delta)


func take_damage(amount: float) -> void:
	health -= amount
	call_deferred("_spawn_damage_popup", amount)

	if health <= 0 and not _dead:
		_dead = true
		call_deferred("_drop_xp_and_die")

func _drop_xp_and_die() -> void:
	if not is_inside_tree():
		return

	var xp = xp_scene.instantiate()
	xp.value = xp_value
	xp.global_position = global_position
	get_tree().current_scene.add_child(xp)
	queue_free()


func _spawn_damage_popup(amount: float) -> void:
	if damage_popup_scene == null:
		return
	var p: Node2D = damage_popup_scene.instantiate()
	p.global_position = global_position + Vector2(0, -8)

	p.text = String.num(amount, 1)

	get_parent().add_child(p)
