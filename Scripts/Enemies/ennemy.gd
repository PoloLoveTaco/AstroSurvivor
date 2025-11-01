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
@export var deathParticle: PackedScene

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
	explode()
	queue_free()

func explode():
	var _particle = deathParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)


func _spawn_damage_popup(amount: float) -> void:
	if damage_popup_scene == null:
		return
	var p: Node2D = damage_popup_scene.instantiate()
	p.global_position = global_position + Vector2(0, -8)

	p.text = String.num(amount, 1)

	get_parent().add_child(p)

@onready var timer: Timer = $Timer

var player: CharacterBody2D
var is_player_in_range: bool = false
var is_attack_good: bool = true

func _process(_delta: float) -> void:
	if is_player_in_range and is_attack_good:
		player.take_damage(damage)
		is_attack_good = false
		timer.start()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		is_player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = false
		timer.start()

func _on_timer_timeout() -> void:
	is_attack_good = true
