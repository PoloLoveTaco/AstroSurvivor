extends Upgrade

func _init(_rarity: RARITY, _amount: float, _player: CharacterBody2D) -> void:
	super._init(_rarity, _amount, _player)
	
	title = "Add Speed Projectiles"
	description = "Gain +" + str(int(amount * 100)) + "% projectiles speed."

func apply() -> void:
	super.apply()
	
	player.bullet_speed += player.bullet_speed * amount
