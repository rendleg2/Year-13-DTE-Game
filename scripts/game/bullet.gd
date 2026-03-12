extends Area2D

@export var speed: float = 400.0
@export var damage: float = 10.0
@export var bullet_range: float = 500.0

var traveled: float = 0.0
var direction: Vector2 = Vector2.ZERO
var base_radius: float = 0.0

func _ready():
	direction = Vector2.RIGHT.rotated(rotation)
	
	if $CollisionShape2D.shape is CircleShape2D:
		base_radius = $CollisionShape2D.shape.radius


func _physics_process(delta):
	var move_vec = direction * speed * delta
	position += move_vec
	traveled += move_vec.length()
	
	if traveled >= bullet_range:
		queue_free()


func set_size(multiplier: float):
	scale = Vector2.ONE * multiplier
	
	if $CollisionShape2D.shape is CircleShape2D:
		$CollisionShape2D.shape.radius = base_radius * multiplier
