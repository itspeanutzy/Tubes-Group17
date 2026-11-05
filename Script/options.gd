extends Node

var button_type = null

func _ready():
	$FadeTransition/AnimationPlayer.play("fade_out")
	$BGMSlider.value = Savemanager.bgm_volume
	$SFXSlider.value = Savemanager.sfx_volume

func _on_bgm_slider_value_changed(value: float) -> void:
	Savemanager.bgm_volume = value # JANGAN LUPA INI BIAR KE-SAVE
	var bus_idx = AudioServer.get_bus_index("BGM")
	if value <= 0.01:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	Savemanager.sfx_volume = value # JANGAN LUPA INI BIAR KE-SAVE
	var bus_idx = AudioServer.get_bus_index("SFX")
	if value <= 0.01:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_back_pressed() -> void:
	Savemanager.save_game() 
	button_type = "back"
	$FadeTransition.show()
	$FadeTransition/FadeTimer.start()
	$FadeTransition/AnimationPlayer.play("fade_in")

func _on_fade_timer_timeout() -> void:
	if button_type == "back":
		get_tree().change_scene_to_file("res://Scene/main_menu.tscn")
