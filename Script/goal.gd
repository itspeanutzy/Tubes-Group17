extends Area2D

var _triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if body.is_in_group("Player"):
		_triggered = true
		GameManager.next_level()
