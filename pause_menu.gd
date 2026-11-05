extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	$Button_Manager/BGM.value = Savemanager.bgm_volume
	$Button_Manager/SFX.value = Savemanager.sfx_volume

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if not get_tree().get_first_node_in_group("Player"):
			return
			
		visible = not visible
		get_tree().paused = visible
		
		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_resume_pressed():
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_save_game_pressed() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		Savemanager.player_health = player.health
	Savemanager.save_game()
	print("SAVE DARI PAUSE MENU BERHASIL!")


func _on_quit_to_menu_pressed() -> void:
	visible = false
	get_tree().paused = false
	GameManager.go_to_main_menu()


func _on_bgm_value_changed(value: float) -> void:
	Savemanager.bgm_volume = value
	var bus_idx = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	if value <= 0.01:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)


func _on_sfx_value_changed(value: float) -> void:
	Savemanager.sfx_volume = value
	var bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	if value <= 0.01:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
