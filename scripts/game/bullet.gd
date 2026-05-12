extends Area2D

var speed: float = 400.0
var damage: float = 10.0
var max_range: float = 500.0

var team: String = "player"

var direction: Vector2 = Vector2.ZERO
var distance_travelled: float = 0.0

var can_hit: bool = false

func setup(dir: Vector2):
	direction = dir.normalized()
	rotation = direction.angle()

func _ready():
	# prevents instant self-collision on spawn
	await get_tree().process_frame
	can_hit = true

func _physics_process(delta):

	global_position += direction * speed * delta

	distance_travelled += speed * delta

	if distance_travelled >= max_range:
		queue_free()

func _on_body_entered(body):

	if not can_hit:
		return

	if body == null:
		return

	if body.has_method("get_team") and body.get_team() == team:
		return

	if body.has_method("hit"):
		body.hit(damage)

	queue_free()
