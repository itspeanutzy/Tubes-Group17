extends Area2D

@export var radius := 40.0
@export var warn_time := 0.9      # jeda peringatan sebelum api menyala
@export var active_time := 1.5    # lama api menyala
@export var damage := 15
@export var stun_power := 10.0
@export var tick_interval := 0.5  # jeda antar damage jika player tetap di dalam
@export var knockback_strength := 120.0

var _time := 0.0
var _tick := 0.0
var _burning := false


func _ready() -> void:
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	add_child(shape)


func _physics_process(delta: float) -> void:
	_time += delta

	if not _burning:
		if _time >= warn_time:
			_burning = true
			queue_redraw()
		return

	if _time >= warn_time + active_time:
		queue_free()
		return

	_tick -= delta
	if _tick <= 0.0:
		_tick = tick_interval
		for body in get_overlapping_bodies():
			if body.is_in_group("Player"):
				var push := (body.global_position - global_position).normalized()
				body.take_hit(damage, stun_power, push * knockback_strength, self)


func _draw() -> void:
	if _burning:
		draw_circle(Vector2.ZERO, radius, Color(1.0, 0.4, 0.0, 0.6))      # api menyala
	else:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(1.0, 0.4, 0.0, 0.8), 2.0)  # peringatan
