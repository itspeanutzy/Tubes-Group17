extends CharacterBody2D

signal died

@export var SPEED := 20
@export var acceleration := 2000
@export var health := 40
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
var knockback := Vector2.ZERO
var player: Node2D = null
var is_dead = false

func _ready():
	add_to_group("Enemy")
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if is_dead or player == null:
		return
		
	var direction = (player.global_position - global_position).normalized()
	knockback = knockback.move_toward(Vector2.ZERO, 600 * delta)
	velocity = direction * SPEED + knockback
	move_and_slide()
	
	if velocity.length() > 0.1:
		if animated_sprite_2d.animation != "walk":
			animated_sprite_2d.play("walk")
		if velocity.x != 0:
			animated_sprite_2d.flip_h = velocity.x < 0

func take_damage(amount: int, knockback_force := Vector2.ZERO):
	if is_dead : return
	health -= amount
	knockback = knockback_force
	
	if health <= 0:
		is_dead = true
		died.emit()
		queue_free()
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
