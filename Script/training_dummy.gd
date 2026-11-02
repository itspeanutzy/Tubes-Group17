extends CharacterBody2D

enum State { WAIT, WINDUP, STRIKE, RECOVER, STUN }

const WAIT_TIME := 1.2
const WINDUP_TIME := 0.5
const STRIKE_TIME := 0.15
const RECOVER_TIME := 0.5
const STUN_TIME := 2.0
const STUN_DAMAGE_BONUS := 1.5

@export var attack_damage := 15
@export var attack_stun := 30.0
@export var attack_knockback := 200.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var stun_gauge: StunGauge = $StunGauge


var state := State.WAIT
var state_time := 0.0
var knockback := Vector2.ZERO
var health := 100


func _ready() -> void:
	add_to_group("Enemy")
	hitbox.monitoring = false
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	stun_gauge.stunned.connect(_on_stunned)


func _physics_process(delta: float) -> void:
	state_time += delta
	knockback = knockback.move_toward(Vector2.ZERO, 600 * delta)
	velocity = knockback
	move_and_slide()

	match state:
		State.WAIT:
			if state_time >= WAIT_TIME:
				change_state(State.WINDUP)
		State.WINDUP:
			if state_time >= WINDUP_TIME:
				change_state(State.STRIKE)
		State.STRIKE:
			if state_time >= STRIKE_TIME:
				change_state(State.RECOVER)
		State.RECOVER:
			if state_time >= RECOVER_TIME:
				change_state(State.WAIT)
		State.STUN:
			if state_time >= STUN_TIME:
				stun_gauge.release()
				change_state(State.WAIT)


func change_state(new_state: State) -> void:
	state = new_state
	state_time = 0.0
	hitbox.set_deferred("monitoring", new_state == State.STRIKE)
	match new_state:
		State.WINDUP:
			sprite.modulate = Color.YELLOW
		State.STRIKE:
			sprite.modulate = Color.RED
		State.STUN:
			sprite.modulate = Color(0.5, 0.8, 1.0)
		_:
			sprite.modulate = Color.WHITE


func _on_stunned() -> void:
	change_state(State.STUN)


func take_hit(damage: int, stun_power: float, knockback_force: Vector2, _attacker: Node2D) -> void:
	if state == State.STUN:
		damage = int(damage * STUN_DAMAGE_BONUS)
	health -= damage
	knockback = knockback_force
	print("dummy hp: ", health)
	sprite.self_modulate = Color.RED
	create_tween().tween_property(sprite, "self_modulate", Color.WHITE, 0.15)
	stun_gauge.add(stun_power)


func on_parried(parrier: Node2D, stun_power: float) -> void:
	knockback = (global_position - parrier.global_position).normalized() * 250.0
	change_state(State.RECOVER)   # the attack is interrupted first...
	stun_gauge.add(stun_power)    # ...then, if the gauge fills, STUN overrides RECOVER


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name != "Hurtbox":
		return
	var target = area.get_parent()
	if not target.is_in_group("Player"):
		return
	if target.has_method("take_hit"):
		var push: Vector2 = (target.global_position - global_position).normalized() * attack_knockback
		target.take_hit(attack_damage, attack_stun, push, self)
