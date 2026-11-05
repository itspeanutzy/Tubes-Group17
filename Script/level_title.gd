extends Node

@export var title_text: String = "Level 3\nBoss"
@export var show_time: float = 1.5
@export var fade_time: float = 1.0
@export var font_size: int = 48


func _ready() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	var label := Label.new()
	label.text = title_text
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 8)
	label.modulate.a = 0.0
	layer.add_child(label)

	var tween := create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(show_time)
	tween.tween_property(label, "modulate:a", 0.0, fade_time)
	tween.tween_callback(layer.queue_free)
