extends Area2D

var speed: float = 400.0
var damage: float = 10.0
var bullet_range: float = 500.0
var direction: Vector2 = Vector2.ZERO
var start_position: Vector2

var team = "player"

func _ready():
	start_position = global_position
	direction = Vector2.RIGHT.rotated(rotation)

func _process(delta):
	position += direction * speed * delta

	if global_position.distance_to(start_position) >= bullet_range:
		queue_free()

func set_size(size_value):
	scale = Vector2.ONE * size_value


func _on_body_entered(body):
	if team == "player":
		if not body.has_method("player"):
			if body.has_method("hit"):
				body.hit(damage)
			queue_free() 
	else:
		if not body.has_method("Pathfind"):
			if body.has_method("hit") and not body.has_method("Pathfind"):
				body.hit(damage)
			queue_free()
