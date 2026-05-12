extends CharacterBody2D

@export var speed: float = 200.0

@export var ability_speed: float = 12.0
@export var ability_duration: float = 0.2
@export var ability_cooldown: float = 0.5

var ability_active: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var ability_timer: float = 0.0
var can_ability: bool = true
var cooldown_timer: float = 0.0
var free_dash: bool = false

@export var bullet_scene: PackedScene
@export var bullet_size: float = 1.0
@export var bullet_speed: float = 400.0
@export var bullet_damage: float = 10.0
@export var bullet_range: float = 500.0
@export var bullet_spread: float = 0.0
@export var bullet_count: int = 1
@export var auto_fire_active: bool = false
@export var fire_rate: float = 0.2

var fire_timer: float = 0.0

func _ready():
	add_to_group("player")
	randomize()

func _physics_process(delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")

	if Input.is_action_just_pressed("shift") and input_direction != Vector2.ZERO and can_ability:
		ability_active = true
		can_ability = false
		ability_timer = ability_duration
		cooldown_timer = ability_cooldown
		dash_direction = input_direction.normalized()

	var current_speed = speed * ability_speed if ability_active else speed

	if ability_active:
		if free_dash:
			velocity = input_direction * current_speed
		else:
			velocity = dash_direction * current_speed
	else:
		velocity = input_direction * speed

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
			shoot_bullet()
			fire_timer = fire_rate
	else:
		if Input.is_action_just_pressed("Shoot") and fire_timer <= 0:
			shoot_bullet()
			fire_timer = fire_rate

func shoot_bullet():
	if bullet_scene == null:
		print("No bullet scene assigned")
		return

	for i in range(bullet_count):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position

		var dir = (get_global_mouse_position() - global_position).normalized()

		var spread = deg_to_rad(randf_range(-bullet_spread, bullet_spread))
		dir = dir.rotated(spread)

		bullet.rotation = dir.angle()

		bullet.speed = bullet_speed
		bullet.damage = bullet_damage
		bullet.bullet_range = bullet_range

		if bullet.has_method("set_size"):
			bullet.set_size(bullet_size)

		get_tree().current_scene.add_child(bullet)

func reset_after_shop():
	ability_active = false
	ability_timer = 0.0
	cooldown_timer = 0.0
	can_ability = true
	velocity = Vector2.ZERO
	
func player():
	pass
