extends Node


func _ready():
	$FadeTransition/AnimationPlayer.play("fade_out")

func _on_quitmenu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/main_menu.tscn")
