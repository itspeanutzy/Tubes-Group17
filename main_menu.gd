extends Node

var button_type = null

func _ready():
	$FadeTransition/AnimationPlayer.play("fade_out")

func _on_start_pressed():
	button_type = "start"
	$FadeTransition.show()
	$FadeTransition/FadeTimer.start()
	$FadeTransition/AnimationPlayer.play("fade_in")

func _on_options_pressed():
	button_type = "options"
	$FadeTransition.show()
	$FadeTransition/FadeTimer.start()
	$FadeTransition/AnimationPlayer.play("fade_in")

func _on_quit_pressed():
	get_tree().quit()


func _on_fade_timer_timeout():
	if button_type == "start":
		get_tree().change_scene_to_file("res://main.tscn")
	elif button_type == "options":
		get_tree().change_scene_to_file("res://options.tscn")
