extends CharacterBody2D

@onready var Target = $"../TestPlayer"
var HP = 100
var Target_Position
var Current_Position
@export var Movement_Speed = 60 # exported for testing purpuses, once good value found set it in code
var Next_Step
var Velocity
var aggro = false
@onready var navigation_agent_2d = $NavigationAgent2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if aggro == true:
		_on_follow_follow()
		Pathfind(delta)

func _on_follow_follow():
	# will set pathfind desination to player
	if Target_Position != Target.position:
		Target_Position = Target.position
		navigation_agent_2d.target_position = Target_Position
		
func Pathfind(delta):
	#moves the enemy closer to the next pathfind point
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


func _on_area_2d_body_entered(body):
	if body == Target:
		aggro = true
