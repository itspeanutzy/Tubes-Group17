extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar

func _process(_delta):
	var player = get_tree().get_first_node_in_group("Player")
	
	if player:
		visible = true
		health_bar.value = player.health
	else:
		visible = false
