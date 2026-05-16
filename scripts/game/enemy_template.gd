extends CharacterBody2D

@export var weapon: PackedScene = preload("res://Scenes/entities/Bullet.tscn") #select weapon
var weaponInstance
@onready var Target = $"../../Player"
var HP = 100
var Target_Position
var Current_Position
@export var Movement_Speed = 60.0  # exported for testing purpuses, once good value found set it in code
@export var type: String = "normal"
var Next_Step
var Velocity
var aggro = false
var timer = false

@onready var navigation_agent_2d = $NavigationAgent2D
var can_shoot = false

var data = {}

func _ready() -> void: #spawn in the enemys weapon
	aggro = false
	GlobalVaribles.enemy_total +=1

	data = GlobalVaribles.enemy_stats[type]
	$Timer.wait_time = data["firerate"]
	HP = data["health"]
	Movement_Speed = data["movement_speed"]
	if type == 'boss':
		$AnimatedSprite2D.play("purple")
		$AnimatedSprite2D.scale = Vector2(1, 1)
		$CollisionShape2D.shape.radius = 12
	elif  type == "shotgun":
		$AnimatedSprite2D.play("purple")
	elif type == "normal":
		$AnimatedSprite2D.play("red")
	
func _physics_process(delta: float) -> void:
	$ProgressBar.value = HP
	if HP <= 0:
		GlobalVaribles.enemy_total -=1
		queue_free()
	if aggro == true:
		if timer == false:
			$Timer.start()
			$ProgressBar.max_value = HP
			$ProgressBar.visible = true
			timer = true
		shoot()
		_on_follow_follow()
		Pathfind(delta)

func _on_follow_follow(): # will set pathfind desination to player
	if Target_Position != Target.global_position:
		Target_Position = Target.global_position
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
	if body.has_method("player"):
		aggro = true
		$Timer.start()

func shoot():
	if can_shoot == true:
		for i in range(GlobalVaribles.enemy_stats[type]["bullets"]):
			var spread = deg_to_rad(randf_range(-GlobalVaribles.enemy_stats[type]["spread"], GlobalVaribles.enemy_stats[type]["spread"]))
			can_shoot = false
			var bullet = weapon.instantiate()
			
			bullet.damage = GlobalVaribles.enemy_stats[type]["damage"]
			var dir = (Target.global_position - self.global_position)
			dir = dir.rotated(spread)
			bullet.global_position = global_position
			bullet.speed = GlobalVaribles.enemy_stats[type]["bullet_speed"]
			bullet.team = "enemy"
			bullet.setup(dir)
			
			get_tree().current_scene.add_child(bullet)

func hit(damage):
	if aggro == true:
		HP -= damage
	


func _on_timer_timeout():
	can_shoot = true
