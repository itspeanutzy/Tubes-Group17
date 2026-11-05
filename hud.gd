extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var kill_label: Label = $KillCounter

var connected_level = null

func _process(_delta):
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		visible = true
		health_bar.value = player.health
		
		var current_level = get_tree().current_scene
		if current_level != connected_level:
			connected_level = current_level
			
			if connected_level and connected_level.has_signal("kills_changed"):
				if not connected_level.kills_changed.is_connected(_on_kills_changed):
					connected_level.kills_changed.connect(_on_kills_changed)
					print("HUD tersambung ke: ", connected_level.name)
	else:
		visible = false
		if kill_label:
			kill_label.visible = false

func _on_kills_changed(current: int, required: int):
	if kill_label:
		kill_label.visible = true
		kill_label.text = "Kills: " + str(current) + "/" + str(required)
		print("Update UI Kill: ", kill_label.text)
