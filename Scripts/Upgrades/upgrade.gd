extends Node
class_name Upgrade

enum RARITY { COMMUN, EPIC, LEGENDARY }

const COLORS := {
	RARITY.COMMUN: Color(0.0, 0.771, 0.188, 0.2),
	RARITY.EPIC: Color(0.742, 0.135, 1.0, 0.2),
	RARITY.LEGENDARY: Color(0.926, 0.812, 0.0, 0.2),
}

@export var color: Color
@export var rarity: RARITY
@export var amount: float

@export var title: String
@export var description: String

var player: CharacterBody2D

func _init(_rarity: RARITY, _amount: float, _player: CharacterBody2D) -> void:
	rarity = _rarity
	color = COLORS[rarity]
	amount = _amount
	player = _player

func apply() -> void:
	pass
