extends Camera2D

@export var shake_intensity: float = 10.0
@export var shake_duration: float = 0.2

var shake_timer: float = 0.0
var original_offset: Vector2

func _ready() -> void:
	original_offset = offset

func _process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		offset = original_offset + Vector2(
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_intensity
	else:
		offset = original_offset

func start_shake(intensity: float = 10.0, duration: float = 0.2) -> void:
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
