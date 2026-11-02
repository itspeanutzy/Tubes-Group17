extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 3.0

var time_elapsed: float = 0.0
var player: Node2D

func _ready():
	player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	if player == null: return
	
	time_elapsed += delta
	if time_elapsed >= spawn_interval:
		time_elapsed = 0.0
		spawn_enemy()

func spawn_enemy():
	if enemy_scene == null: return
	
	var enemy = enemy_scene.instantiate()
	
	enemy.global_position = global_position
	
	add_child(enemy)
