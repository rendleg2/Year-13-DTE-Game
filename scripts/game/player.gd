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
var free_dash: bool = false # free dashing

@export var bullet_scene: PackedScene
@export var bullet_size: float = 1.0
@export var bullet_speed: float = 400.0
@export var bullet_damage: float = 10.0
@export var bullet_range: float = 500.0

func _ready():
	add_to_group("Cards")

func _physics_process(delta):
	var input_direction = Input.get_vector("left","right","up","down")

	# Dash
	if Input.is_action_just_pressed("shift") and input_direction != Vector2.ZERO and can_ability:
		ability_active = true
		can_ability = false
		ability_timer = ability_duration
		cooldown_timer = ability_cooldown
		if not free_dash:
			dash_direction = input_direction.normalized()

	var current_speed = speed * ability_speed if ability_active else speed
	
	if ability_active and not free_dash:
		velocity = dash_direction * current_speed
	else:
		velocity = input_direction * current_speed

	if ability_active:
		ability_timer -= delta
		if ability_timer <= 0:
			ability_active = false

	if not can_ability:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_ability = true

	move_and_slide()

	# Shooting
	if Input.is_action_just_pressed("Shoot"):
		shoot_bullet()


func shoot_bullet():
	if not bullet_scene:
		print("No bullet scene assigned!")
		return
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	
	var dir = (get_global_mouse_position() - global_position).normalized()
	bullet.rotation = dir.angle()
	
	bullet.speed = bullet_speed
	bullet.damage = bullet_damage
	bullet.bullet_range = bullet_range
	
	bullet.set_size(bullet_size)
	
	get_tree().current_scene.add_child(bullet)
