extends CharacterBody2D

@export_group("Stat")
@export var health := 300
@export var move_speed := 60.0

@export_group("Jarak")
@export var trigger_range := 200  # di luar jarak ini, musuh diam
@export var min_distance := 30    # lebih dekat dari ini, musuh mundur
@export var max_distance := 100   # lebih jauh dari ini, musuh mendekat

@export_group("Serangan")
@export var orb_scene: PackedScene
@export var fire_scene: PackedScene
@export var attack_cooldown := 3
@export var fire_chance := 0.4       # peluang memilih api (0.0 sampai 1.0)
@export var orbs_per_cast := 3
@export var orb_spread_degrees := 15.0

@export_group("Teleport")
@export var hits_to_teleport := 3
@export var teleport_min_distance := 100
@export var teleport_max_distance := 150

var player: Node2D = null
var knockback := Vector2.ZERO
var attack_timer := 1.0
var hit_count := 0

var arena_rect := Rect2()
var has_arena := false


func _ready() -> void:
	add_to_group("Enemy")             # agar bisa dipukul player
	add_to_group("NoContactDamage")   # agar tidak melukai player saat bersentuhan
	player = get_tree().get_first_node_in_group("Player")
	
	var bounds := get_tree().get_first_node_in_group("ArenaBounds")
	if bounds != null:
		var tl: Vector2 = bounds.get_node("TopLeft").global_position
		var br: Vector2 = bounds.get_node("BottomRight").global_position
		arena_rect = Rect2(tl, br - tl)
		has_arena = true


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return

	knockback = knockback.move_toward(Vector2.ZERO, 800.0 * delta)

	var to_player := player.global_position - global_position
	var dist := to_player.length()
	var move_dir := Vector2.ZERO

	if dist <= trigger_range:
		# Jaga jarak
		if dist < min_distance:
			move_dir = -to_player.normalized()
		elif dist > max_distance:
			move_dir = to_player.normalized()

		# Serang tiap cooldown habis
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = attack_cooldown
			_attack()

	velocity = move_dir * move_speed + knockback
	move_and_slide()


func _attack() -> void:
	if fire_scene != null and randf() < fire_chance:
		_cast_fire()
	else:
		_cast_orbs()


func _cast_orbs() -> void:
	if orb_scene == null:
		return
	var base_dir := (player.global_position - global_position).normalized()
	for i in orbs_per_cast:
		var offset := (i - (orbs_per_cast - 1) / 2.0) * deg_to_rad(orb_spread_degrees)
		var orb = orb_scene.instantiate()
		orb.direction = base_dir.rotated(offset)
		get_tree().current_scene.add_child(orb)
		orb.global_position = global_position


func _cast_fire() -> void:
	var fire = fire_scene.instantiate()
	get_tree().current_scene.add_child(fire)
	fire.global_position = player.global_position  # lokasi dikunci saat cast


func _teleport() -> void:
	if not is_instance_valid(player):
		return

	for i in 20:
		var angle := randf() * TAU
		var dist := randf_range(teleport_min_distance, teleport_max_distance)
		var target := player.global_position + Vector2.RIGHT.rotated(angle) * dist

		# Tolak titik di luar batas map
		if has_arena and not arena_rect.has_point(target):
			continue
		# Tolak titik di dalam tembok
		if test_move(Transform2D(0.0, target), Vector2.ZERO):
			continue

		global_position = target
		break

	attack_timer = maxf(attack_timer, 1.0)


# Dipanggil otomatis oleh player saat Hitbox mengenai Hurtbox musuh ini
func take_hit(damage: int, _stun_power: float, knockback_force: Vector2, _attacker: Node2D) -> void:
	health -= damage
	knockback = knockback_force

	modulate = Color.RED
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.15)

	if health <= 0:
		queue_free()
		return

	hit_count += 1
	if hit_count >= hits_to_teleport:
		hit_count = 0
		_teleport.call_deferred()  # ditunda agar aman dari callback fisika
