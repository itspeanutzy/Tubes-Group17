extends CharacterBody2D

@export var SPEED := 100
@export var acceleration := 2000
@export var health := 200
@onready var animated_sprite_2d : AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox : Area2D = $Hitbox

var is_attacking = false
var is_dead = false
var animation_direction: String = "down"
var animation_state : String = ""

func _ready():
	add_to_group("Player")

func update_sprite_direction(input:Vector2) -> void:
	match input:
		Vector2.DOWN:
			animation_direction = "down"	
		Vector2.UP:
			animation_direction = "up"
		Vector2.LEFT:
			animation_direction = "left"
		Vector2.RIGHT:
			animation_direction = "right"

func update_sprite() -> void:
	if velocity.length() > 0:
		animation_state = "walk_"
	else:	
		animation_state = "idle_"


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not is_attacking:
		player_attack()
	
	var direction := Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	
	if not is_attacking:
		update_sprite_direction(direction)
		update_sprite()
		animated_sprite_2d.play(animation_state+animation_direction)
	
		velocity.x = move_toward(velocity.x, direction.x*SPEED, acceleration * delta)
		velocity.y = move_toward(velocity.y, direction.y*SPEED, acceleration * delta)
	
	move_and_slide()
	
func player_attack():
	velocity = Vector2.ZERO
	is_attacking = true
	$SwingSound.play()
	match animation_direction:
		"left":
			animated_sprite_2d.flip_h = true
			animated_sprite_2d.play("attack_side")
			attack_hitbox.rotation_degrees = 180
		"right":
			animated_sprite_2d.flip_h = false
			animated_sprite_2d.play("attack_side")
			attack_hitbox.rotation_degrees = 0
		"up":
			animated_sprite_2d.play("attack_up")
			attack_hitbox.rotation_degrees = -90
		"down":
			animated_sprite_2d.play("attack_down")
			attack_hitbox.rotation_degrees = 90
			
	await get_tree().create_timer(0.1).timeout
	attack_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack_hitbox.monitoring = false		
	
	await  animated_sprite_2d.animation_finished
	is_attacking = false


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		health -= 10
		animated_sprite_2d.modulate = Color.RED
		await get_tree().create_timer(0.1).timeout
		animated_sprite_2d.modulate = Color.WHITE
	
		if health <= 0:
			queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		var enemy = area.get_parent()
		if enemy.has_method("take_damage"):
			enemy.take_damage(20)
