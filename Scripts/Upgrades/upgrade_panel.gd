extends Control

@onready var b1 := $Panel/Upgrades/Upgrade1

@onready var b2 := $Panel/Upgrades/Upgrade2

@onready var b3 := $Panel/Upgrades/Upgrade3

var u1: Upgrade
var u2: Upgrade
var u3: Upgrade

func set_btn(btn, color):
	var base := StyleBoxFlat.new()
	base.bg_color = color
	base.border_color = Color(1, 1, 1)
	base.set_border_width_all(2)

	var hover := base.duplicate()
	hover.bg_color = Color(0.2, 0.3, 0.5)
	hover.bg_color = color
	hover.bg_color.a = 0.4

	var pressed := base.duplicate()
	pressed.bg_color = Color(0.1, 0.15, 0.25)

	btn.add_theme_stylebox_override("normal", base)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("disabled", base)
	btn.add_theme_stylebox_override("focus", base)

	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_color_hover", Color.WHITE)
	btn.add_theme_color_override("font_color_pressed", Color(0.9, 0.9, 0.9))

func set_upgrades():
	var pool = UpgradeManager.upgrades.duplicate()
	pool.shuffle()
	var choices = pool.slice(0, 3)
	u1 = choices[0]
	u2 = choices[1]
	u3 = choices[2]
	
	$Panel/Upgrades/Upgrade1/Titre.text = u1.title
	$Panel/Upgrades/Upgrade1/Description.text = u1.description
	set_btn($Panel/Upgrades/Upgrade1, u1.color)
	
	$Panel/Upgrades/Upgrade2/Titre.text = u2.title
	$Panel/Upgrades/Upgrade2/Description.text = u2.description
	$Panel/Upgrades/Upgrade2.add_theme_color_override("bg_color", u2.color) 
	set_btn($Panel/Upgrades/Upgrade2, u2.color)
	
	$Panel/Upgrades/Upgrade3/Titre.text = u3.title
	$Panel/Upgrades/Upgrade3/Description.text = u3.description
	$Panel/Upgrades/Upgrade3.add_theme_color_override("bg_color", u3.color) 
	set_btn($Panel/Upgrades/Upgrade3, u3.color)
	
func _ready() -> void:
	get_tree().paused = true

func close():
	get_tree().paused = false
	queue_free()

func _on_upgrade_1_pressed() -> void:
	u1.apply()
	close()

func _on_upgrade_2_pressed() -> void:
	u2.apply()
	close()

func _on_upgrade_3_pressed() -> void:
	u3.apply()
	close()
