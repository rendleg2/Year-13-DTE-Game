extends CanvasLayer

@export var card_scene: PackedScene
@onready var container = $Container
@onready var player = get_tree().get_first_node_in_group("player")

var upgrades = [
		{"effects": 
			[{"type": "speed", "value": 25},
			{"type": "bullet_damage", "value": 5}],
		"image": "res://assets/tilesheet/aaa.png"},
		
		{"effects": 
			[{"type": "auto_fire_toggle"},
			{"type": "free_dash_toggle"}],
		"image": "res://assets/tilesheet/bossslime.png"}
		]

func _ready():
	await get_tree().process_frame
	open_shop()

func open_shop():

	print("SHOP OPENED")

	if card_scene == null:
		print("ERROR: card_scene not assigned")
		return

	visible = true
	get_tree().paused = true

	for c in container.get_children():
		c.queue_free()

	var picks = upgrades.duplicate()
	picks.shuffle()

	if picks.size() > 3:
		picks = picks.slice(0, 3)

	for item in picks:

		var card = card_scene.instantiate()

		card.data = item
		card.player = player
		card.shop = self

		container.add_child(card)

func on_card_picked(card):

	print("CARD PICKED")

	for c in container.get_children():
		if c != card:
			c.queue_free()

	visible = false
	get_tree().paused = false

	if player:
		player.reset_after_shop()
	for i in 10:
		await get_tree().physics_frame
	get_tree().change_scene_to_file(str("res://Scenes/game_loop/map_generator.tscn"))
