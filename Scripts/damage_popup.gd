extends Node2D

@export var text: String = "10"
@export var color: Color = Color(1, 1, 1, 1)
@export var duration: float = 1
@export var rise: float = 28.0
@export var jitter: float = 6.0
@export var scale_mult: float = 1.0

@onready var font = preload("res://Assets/Fonts/Bing Bam Boum.ttf")

var _label: Label

func _ready() -> void:
	_label = Label.new()
	add_child(_label)
	_label.text = text
	_label.modulate = color
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.scale = Vector2.ONE * (2 * scale_mult)
	_label.add_theme_font_override("font", font)
	z_index = 1000
	z_as_relative = false

	# petit décalage latéral aléatoire
	global_position += Vector2(randf_range(-jitter, jitter), 0)

	var tw = create_tween()
	tw.tween_property(self, "global_position", global_position + Vector2(0, -rise), duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(_label, "modulate:a", 0.0, duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.finished.connect(queue_free)
