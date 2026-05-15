extends CharacterBody2D

@export var bullet_scene: PackedScene = load("res://Scenes/entities/Bullet.tscn")
var health
var speed
var ability_speed
var ability_duration
var ability_cooldown

var bullet_damage
var bullet_speed
var bullet_range
var bullet_size
var bullet_count
var bullet_spread

var auto_fire_active
var free_dash

var ability_active = false
var dash_direction = Vector2.ZERO
var ability_timer = 0.0
var can_ability = true
var cooldown_timer = 0.0
var fire_rate = 0.4

var fire_timer = 0.0

func _ready():
	add_to_group("player")
	load_from_global()

func load_from_global():
	fire_rate = Global.fire_rate
	health = Global.health
	$ProgressBar.max_value = health
	speed = Global.speed
	ability_speed = Global.ability_speed
	ability_duration = Global.ability_duration
	ability_cooldown = Global.ability_cooldown

	bullet_damage = Global.bullet_damage
	bullet_speed = Global.bullet_speed
	bullet_range = Global.bullet_range
	bullet_size = Global.bullet_size
	bullet_count = Global.bullet_count
	bullet_spread = Global.bullet_spread

	auto_fire_active = Global.auto_fire_active
	free_dash = Global.free_dash

func _physics_process(delta):
	$ProgressBar.value = health
	if health <= 0:
		get_tree().change_scene_to_file("res://Scenes/game_loop/end.tscn")

	var input = Input.get_vector("left", "right", "up", "down")

	if Input.is_action_just_pressed("shift") and input != Vector2.ZERO and can_ability:
		ability_active = true
		can_ability = false
		ability_timer = ability_duration
		cooldown_timer = ability_cooldown
		dash_direction = input.normalized()

	var current_speed = speed * ability_speed if ability_active else speed

	if ability_active:
		if free_dash:
			velocity = input * current_speed
		else:
			velocity = dash_direction * current_speed
	else:
		velocity = input * speed

	if ability_active:
		ability_timer -= delta
		if ability_timer <= 0:
			ability_active = false

	if not can_ability:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_ability = true

	move_and_slide()

	if fire_timer > 0:
		fire_timer -= delta

	if auto_fire_active:
		if Input.is_action_pressed("Shoot") and fire_timer <= 0:
			shoot()
			fire_timer = fire_rate
	else:
		if Input.is_action_just_pressed("Shoot") and fire_timer <= 0:
			shoot()
			fire_timer = fire_rate

func shoot():

	for i in range(bullet_count):

		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet) # Where we assign the bullet scene

		var dir = (get_global_mouse_position() - global_position).normalized()  # Shoots bullet towards the mouse

		var spread = deg_to_rad(randf_range(-bullet_spread, bullet_spread))
		dir = dir.rotated(spread) # This adds spread to the bullet based on the spread value given

		bullet.global_position = global_position + dir * 20

		bullet.setup(dir) # Direction based on line 105

		bullet.speed = bullet_speed # Code handling bullet behaviour
		bullet.damage = bullet_damage
		bullet.max_range = bullet_range
		bullet.team = "player" 

func save_to_global():

	Global.speed = speed
	Global.ability_speed = ability_speed
	Global.ability_duration = ability_duration
	Global.ability_cooldown = ability_cooldown

	Global.bullet_damage = bullet_damage
	Global.bullet_speed = bullet_speed
	Global.bullet_range = bullet_range
	Global.bullet_size = bullet_size
	Global.bullet_count = bullet_count
	Global.bullet_spread = bullet_spread

	Global.auto_fire_active = auto_fire_active
	Global.free_dash = free_dash

func hit(damege):
	health -= damege

func player():
	pass
