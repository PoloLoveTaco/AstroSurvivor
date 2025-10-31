extends ParallaxBackground

@export var scroll_speed: float = 0.5
@onready var player: Node2D = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if player:
		scroll_offset = -player.global_position * scroll_speed
