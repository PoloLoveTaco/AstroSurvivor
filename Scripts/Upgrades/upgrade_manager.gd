extends Node

@export var pool_scripts: Array
@export var upgrades: Array[Upgrade]
@export var player: CharacterBody2D

@onready var upgrade_ui: PackedScene = preload("res://Scenes/Menus/upgrade_panel.tscn")

func _ready() -> void:
	
	player = get_tree().get_nodes_in_group("Player")[0]
	
	pool_scripts = [
		preload("res://Scripts/Upgrades/u_move_speed.gd"),
		preload("res://Scripts/Upgrades/u_nb_proj.gd"),
		preload("res://Scripts/Upgrades/u_attack_speed.gd"),
		preload("res://Scripts/Upgrades/u_speed_proj.gd"),
		
	]
	
	upgrades = [
		# gain 10% move speed
		pool_scripts[0].new(Upgrade.RARITY.COMMUN, 0.1, player),
		# gain 20% move speed
		pool_scripts[0].new(Upgrade.RARITY.EPIC, 0.2, player),
		# gain 30% move speed
		pool_scripts[0].new(Upgrade.RARITY.LEGENDARY, 0.3, player),
		
		pool_scripts[1].new(Upgrade.RARITY.COMMUN, 1, player),
		pool_scripts[1].new(Upgrade.RARITY.EPIC, 2, player),
		pool_scripts[1].new(Upgrade.RARITY.LEGENDARY, 3, player),
		
		pool_scripts[2].new(Upgrade.RARITY.COMMUN, 0.1, player),
		pool_scripts[2].new(Upgrade.RARITY.EPIC, 0.2, player),
		pool_scripts[2].new(Upgrade.RARITY.LEGENDARY, 0.3, player),
		
		pool_scripts[3].new(Upgrade.RARITY.COMMUN, 0.1, player),
		pool_scripts[3].new(Upgrade.RARITY.EPIC, 0.2, player),
		pool_scripts[3].new(Upgrade.RARITY.LEGENDARY, 0.3, player),
	]

func run():
	var ui = upgrade_ui.instantiate()
	get_tree().current_scene.get_node("CanvasLayer").add_child(ui)
	ui.set_upgrades()
