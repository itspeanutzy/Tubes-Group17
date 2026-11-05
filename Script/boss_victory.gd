extends Node

@export var boss: Node
@export var delay: float = 3.0 
@export var display_time: float = 5.0 	

var _triggered: bool = false


func _ready() -> void:
	if boss == null:
		push_warning("BossVictory: Boss belum diisi di Inspector")
		return
	if not boss.has_signal("died"):
		push_warning("BossVictory: Boss tidak punya signal 'died'")
		return
	boss.connect("died", _on_boss_died)


func _on_boss_died() -> void:
	if _triggered:
		return
	_triggered = true
	
	await get_tree().create_timer(delay).timeout
	
	_show_victory_text()
	
	await get_tree().create_timer(display_time).timeout
	
	GameManager.go_to_main_menu()


func _show_victory_text():
	var layer := CanvasLayer.new()
	add_child(layer)
	
	var label := Label.new()
	label.text = "VICTORY!\n\nBoss Defeated." 
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	label.add_theme_font_size_override("font_size", 64)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 8)
	
	layer.add_child(label)
	
	label.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 1.0)
