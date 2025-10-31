extends Upgrade

func _init(_rarity: RARITY, _amount: float, _player: CharacterBody2D) -> void:
	super._init(_rarity, _amount, _player)
	
	title = "Gain Attack Speed"
	description = "Gain " + str(int(amount * 100)) + "% attack speed."

func apply() -> void:
	super.apply()
	
	player.shooting_timer.wait_time -= player.shooting_timer.wait_time * amount
