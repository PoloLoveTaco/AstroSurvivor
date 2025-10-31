extends Collectable

@export var value: float

func _on_collected(player: CharacterBody2D) -> void:
	super._on_collected(player)
	
	player.get_xp(value)
	
	queue_free()
