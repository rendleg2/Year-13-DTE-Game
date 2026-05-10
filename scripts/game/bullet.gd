extends Area2D

var speed: float = 400.0
var damage: float = 10.0
var bullet_range: float = 500.0

var direction: Vector2 = Vector2.ZERO
var start_position: Vector2

func _ready():
	start_position = global_position
	direction = Vector2.RIGHT.rotated(rotation)

func _process(delta):
	position += direction * speed * delta

	if global_position.distance_to(start_position) >= bullet_range:
		queue_free()

func set_size(size_value):
	scale = Vector2.ONE * size_value
