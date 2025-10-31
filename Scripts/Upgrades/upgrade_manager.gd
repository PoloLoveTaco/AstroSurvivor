extends Node

@export var pool_scripts: Array
@export var upgrades: Array[Upgrade]
@export var player: CharacterBody2D

@onready var upgrade_ui: PackedScene = preload("res://Scenes/upgrade_panel.tscn")

func _ready() -> void:
	
	player = get_tree().get_nodes_in_group("Player")[0]
	
	pool_scripts = [
		preload("res://Scripts/Upgrades/u_move_speed.gd")
	]
	
	upgrades = [
		# gain 10% move speed
		pool_scripts[0].new(Upgrade.RARITY.COMMUN, 0.1, player),
		# gain 20% move speed
		pool_scripts[0].new(Upgrade.RARITY.EPIC, 0.2, player),
		# gain 30% move speed
		pool_scripts[0].new(Upgrade.RARITY.LEGENDARY, 0.3, player),
	]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var ui = upgrade_ui.instantiate()
		get_tree().current_scene.get_node("CanvasLayer").add_child(ui)
		ui.set_upgrades()
