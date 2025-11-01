extends GPUParticles2D

@onready var time_since_screated: int = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - time_since_screated > 10000:
		queue_free()
