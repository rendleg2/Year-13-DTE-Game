extends CharacterBody2D

# Add this player to a group so buttons can find it automatically
func _ready():
	add_to_group("Cards")

# Movement & Dash Settings
@export var speed: float = 200.0
@export var ability_speed: float = 12.0  # modified by button
@export var ability_duration: float = 0.2
@export var ability_cooldown: float = 0.5

# Ability state
var ability_active: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var ability_timer: float = 0.0

var can_ability: bool = true
var cooldown_timer: float = 0.0

# Steerable Dash Toggle (we will make it enable with card)
var free_dash: bool = false

func _physics_process(_delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")

	# Start dash if Shift pressed and off cooldown
	if Input.is_action_just_pressed("shift") and input_direction != Vector2.ZERO and can_ability:
		ability_active = true
		can_ability = false
		ability_timer = ability_duration
		cooldown_timer = ability_cooldown
		if not free_dash:
			dash_direction = input_direction.normalized()

	# Determines speed
	var current_speed = speed * ability_speed if ability_active else speed

	# Movement logic
	if ability_active and not free_dash:
		velocity = dash_direction * current_speed  # Locked dash
	else:
		velocity = input_direction * current_speed  # Normal movement or free dash

	# Update ability timer
	if ability_active:
		ability_timer -= _delta
		if ability_timer <= 0:
			ability_active = false

	# Update cooldown
	if not can_ability:
		cooldown_timer -= _delta
		if cooldown_timer <= 0:
			can_ability = true

	# Move the character
	move_and_slide()
