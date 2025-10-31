extends Upgrade


func _init(_rarity: RARITY, _amount: float, _player: CharacterBody2D) -> void:
	super._init(_rarity, _amount, _player)
	
	title = "Gain Projectiles"
	description = "Gain +" + str(amount) + " projectiles."

func apply() -> void:
	super.apply()
	
	player.nb_proj += amount
