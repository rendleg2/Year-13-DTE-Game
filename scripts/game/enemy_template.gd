extends CharacterBody2D

@export var weapon: PackedScene = load("res://Scenes/entities/Bullet.tscn") #select weapon
var weaponInstance
@onready var Target = $"../../Player"
var HP = 100
var Target_Position
var Current_Position
@export var Movement_Speed = 60 # exported for testing purpuses, once good value found set it in code
var Next_Step
var Velocity
var aggro = false
@onready var navigation_agent_2d = $NavigationAgent2D
var can_shoot = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void: #spawn in the enemys weapon
	pass
	#if weapon:
	#	weaponInstance = weapon.instantiate()
	#	add_child(weaponInstance)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if aggro == true:
		shoot()
		_on_follow_follow()
		Pathfind(delta)
	if HP < 1:
		queue_free()

func _on_follow_follow(): # will set pathfind desination to player
	if Target_Position != Target.position:
		Target_Position = Target.position
		navigation_agent_2d.target_position = Target_Position
		
func Pathfind(_delta): #moves the enemy closer to the next pathfind point
	Current_Position = self.global_position
	Next_Step = navigation_agent_2d.get_next_path_position()
	Velocity = Current_Position.direction_to(Next_Step) * Movement_Speed
	if navigation_agent_2d.avoidance_enabled:
		navigation_agent_2d.set_velocity(Velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(Velocity)
	move_and_slide()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func _on_area_2d_body_entered(body): # if target enters detection range, attack
	if body == Target:
		aggro = true
		$Timer.start()

func shoot():
	if can_shoot == true:
		can_shoot = false
		var bullet = weapon.instantiate()
		bullet.global_position = global_position

		var dir = (Target.position - self.global_position).angle()
		var spread = 0
		#dir = dir.rotated(spread)
		bullet.rotation = dir
		bullet.team = "enemy"
		get_tree().current_scene.add_child(bullet)

func hit(damege):
	HP -= damege

func _on_timer_timeout():
	can_shoot = true
