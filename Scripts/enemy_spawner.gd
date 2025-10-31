extends Node2D

@export_category("General")
@export var min_spawn_distance: float = 2500.0
@export var max_spawn_distance: float = 3000.0
@export var normal_enemy: PackedScene = preload("res://Scenes/NormalEnemy.tscn")
@export var scout_enemy: PackedScene = preload("res://Scenes/ScoutEnemy.tscn")
@export var cruiser_enemy: PackedScene = preload("res://Scenes/CruiserEnemy.tscn")

@export_category("Zones")
@export var zones: Array[ZoneData]
@export var current_zone_index: int = 0
@export var auto_advance_zone: bool = true

@onready var zone_label = $"../CanvasLayer/ZoneLabel"
@onready var wave_label = $"../CanvasLayer/WaveLabel"

var _rng := RandomNumberGenerator.new()
var _player: Node2D

var _next_wave_id: int = 1
var _waves := {}

var _current_wave_idx: int = -1
var _zone_started: bool = false

func _ready() -> void:
	_rng.randomize()
	var players := get_tree().get_nodes_in_group("Player")
	if players.is_empty():
		return
	_player = players[0]

	if zones.is_empty():
		return

	_start_zone(current_zone_index)
	zone_label.text = "Zone: " + str(current_zone_index + 1) + "/12"

func _start_zone(zone_idx: int) -> void:
	if zone_idx < 0 or zone_idx >= zones.size():
		push_warning("EnemySpawner: zone index hors limites.")
		return

	_zone_started = true
	_current_wave_idx = -1
	_try_start_next_wave()

func _try_start_next_wave() -> void:
	var zone := zones[current_zone_index]
	if zone == null:
		return

	_current_wave_idx += 1
	if _current_wave_idx >= zone.waves.size():
		if auto_advance_zone:
			_check_end_zone_periodically()
		return

	wave_label.text = "Wave: " + str(_current_wave_idx + 1) + "/" + str(zone.waves.size())
	
	var wave_data: WaveData = zone.waves[_current_wave_idx]
	var wave_id := _next_wave_id
	_next_wave_id += 1

	_waves[wave_id] = {
		"alive": 0,
		"started_at": Time.get_ticks_msec() / 1000.0,
		"data": wave_data,
		"started_next": false
	}

	_schedule_wave_spawns(wave_id, wave_data)

	_schedule_wave_watchdog(wave_id, wave_data.wave_time_max)

func _schedule_wave_spawns(wave_id: int, data: WaveData) -> void:
	if data.nb_normal_enemy > 0:
		_delay_call(data.time_start_spawn_normal, func(): _spawn_batch(wave_id, normal_enemy, data.nb_normal_enemy))
	if data.nb_scout_enemy > 0:
		_delay_call(data.time_start_spawn_scout, func(): _spawn_batch(wave_id, scout_enemy, data.nb_scout_enemy))
	if data.nb_cruiser_enemy > 0:
		_delay_call(data.time_start_spawn_cruiser, func(): _spawn_batch(wave_id, cruiser_enemy, data.nb_cruiser_enemy))

func _schedule_wave_watchdog(wave_id: int, wave_time_max: float) -> void:
	if wave_time_max <= 0.0: return
	_delay_call(wave_time_max, func():
		if _waves.has(wave_id):
			var info = _waves[wave_id]
			if info.alive > 0 and not info.started_next:
				info.started_next = true
				_waves[wave_id] = info
				_try_start_next_wave()
	)

func _delay_call(delay_sec: float, f: Callable) -> void:
	if get_tree():
		var t := get_tree().create_timer(max(0.0, delay_sec))
		t.timeout.connect(f)

func _spawn_batch(wave_id: int, scene: PackedScene, count: int) -> void:
	if scene == null or _player == null or count <= 0 or not _waves.has(wave_id):
		return
	for i in count:
		var enemy := scene.instantiate()
		add_child(enemy)

		var angle := _rng.randf() * TAU
		var distance = lerp(min_spawn_distance, max_spawn_distance, _rng.randf())
		enemy.global_position = _player.global_position + Vector2(cos(angle), sin(angle)) * distance

		enemy.set_meta("wave_id", wave_id)
		enemy.add_to_group("enemies")
		enemy.health *= (current_zone_index + 1)

		var info = _waves[wave_id]
		info.alive += 1
		_waves[wave_id] = info

		enemy.tree_exited.connect(func():
			_on_enemy_removed(wave_id))

func _on_enemy_removed(wave_id: int) -> void:
	if not _waves.has(wave_id):
		return
	var info = _waves[wave_id]
	info.alive = max(0, info.alive - 1)
	_waves[wave_id] = info

	if info.alive == 0:
		if not info.started_next:
			info.started_next = true
			_waves[wave_id] = info
			_try_start_next_wave()
		_delay_call(0.1, func():
			_waves.erase(wave_id)
			_try_finish_zone_if_needed()
		)

func _check_end_zone_periodically() -> void:
	_delay_call(0.5, func():
		_try_finish_zone_if_needed()
		if _zone_started and auto_advance_zone:
			_check_end_zone_periodically()
	)

func _try_finish_zone_if_needed() -> void:
	var zone := zones[current_zone_index]
	var all_launched := _current_wave_idx >= zone.waves.size()
	var any_alive := false
	for k in _waves.keys():
		if _waves[k].alive > 0:
			any_alive = true
			break

	if all_launched and not any_alive:
		_zone_started = false
		if auto_advance_zone:
			current_zone_index += 1
			if current_zone_index < zones.size():
				zone_label.text = "Zone: " + str(current_zone_index + 1) + "/12"
				_start_zone(current_zone_index)
			else:
				emit_signal_safe("all_zones_completed")

func emit_signal_safe(signal_name: StringName) -> void:
	if has_signal(signal_name):
		emit_signal(signal_name)
