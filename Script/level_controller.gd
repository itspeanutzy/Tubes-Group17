extends Node2D

signal kills_changed(current: int, required: int)
signal gate_opened

@export var kills_required: int = 5
@export var gate_layer: TileMapLayer
@export var gate_cells: Array[Vector2i] = []
@export var open_source_id: int = 0
@export var open_atlas_coords: Array[Vector2i] = []

var kills: int = 0
var _opened: bool = false


func _ready() -> void:
	print("[Controller] siap. kills_required=", kills_required, " gate_layer=", gate_layer)
	# Musuh yang sudah ada di level sejak awal
	get_tree().node_added.connect(_on_node_added)
	await get_tree().process_frame
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		_register_enemy(enemy)
	# Musuh yang muncul belakangan (dari spawner)
	
	kills_changed.emit(kills, kills_required)


func _on_node_added(node: Node) -> void:
	if node is CharacterBody2D and node.has_signal("died"):
		_register_enemy(node)


func _register_enemy(enemy: Node) -> void:
	if enemy.has_signal("died") and not enemy.is_connected("died", _on_enemy_died):
		enemy.connect("died", _on_enemy_died)
		print("[Controller] musuh terdaftar: ", enemy.name)


func _on_enemy_died() -> void:
	print("[Controller] musuh mati. kills=", kills + 1, "/", kills_required)
	if _opened:
		return
	kills += 1
	kills_changed.emit(kills, kills_required)
	if kills >= kills_required:
		_open_gate()


func _open_gate() -> void:
	print("[Controller] membuka gerbang. gate_cells=", gate_cells, " atlas=", open_atlas_coords)
	_opened = true

	for i in gate_cells.size():
		var atlas: Vector2i = open_atlas_coords[i]
		gate_layer.set_cell(gate_cells[i], open_source_id, atlas)

	gate_opened.emit()
	
	for spawner in get_tree().get_nodes_in_group("EnemySpawner"):
		spawner.queue_free()
		
	print("Gerbang terbuka, Spawner dimatikan!")
