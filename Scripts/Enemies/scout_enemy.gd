extends Enemy

@onready var timer: Timer = $Timer

var player: CharacterBody2D
var is_player_in_range: bool = false
var is_attack_good: bool = true

func _process(_delta: float) -> void:
	if is_player_in_range and is_attack_good:
		player.take_damage(damage)
		is_attack_good = false
		timer.start()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		is_player_in_range = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		is_player_in_range = false
		timer.start()

func _on_timer_timeout() -> void:
	is_attack_good = true
