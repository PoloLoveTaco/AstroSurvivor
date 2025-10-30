extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_every: float = 2.0
@export var min_spawn_distance: float = 2500.0
@export var max_spawn_distance: float = 3000.0

var _rng := RandomNumberGenerator.new()
var _player: Node2D

func _ready() -> void:
	_rng.randomize()
	_player = get_tree().get_nodes_in_group("Player")[0]
	_schedule_next_spawn()

func _schedule_next_spawn() -> void:
	get_tree().create_timer(spawn_every).timeout.connect(_on_spawn_timeout)

func _on_spawn_timeout() -> void:
	_spawn_enemy()
	_schedule_next_spawn()

func _spawn_enemy() -> void:
	if enemy_scene == null or _player == null:
		return

	var enemy := enemy_scene.instantiate()
	add_child(enemy)

	var angle := _rng.randf() * TAU
	var distance = lerp(min_spawn_distance, max_spawn_distance, _rng.randf())
	var spawn_pos = _player.global_position + Vector2(cos(angle), sin(angle)) * distance

	enemy.global_position = spawn_pos
