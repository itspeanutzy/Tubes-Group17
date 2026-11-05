extends Node

@export var boss: Node
@export var delay: float = 3.0

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
	GameManager.go_to_main_menu()
