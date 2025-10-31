extends Upgrade


func _init(_rarity: RARITY, _amount: float, _player: CharacterBody2D) -> void:
	super._init(_rarity, _amount, _player)
	
	title = "Gain Move Speed"
	description = "Gain " + str(int(amount * 100)) + "% movement speed."

func apply() -> void:
	super.apply()
	
	player.speed += player.speed * amount
