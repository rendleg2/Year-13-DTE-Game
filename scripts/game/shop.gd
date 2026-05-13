extends CanvasLayer

@export var card_scene: PackedScene

@onready var container = $Container
@onready var state = get_tree().get_first_node_in_group("gamestate")

var upgrades = [
	{
		"effects": [
			{"type": "speed", "value": 25},
			{"type": "bullet_damage", "value": 5}
		],
		"image": "res://assets/tilesheet/healthupgrade.png"
	},

	{
		"effects": [
			{"type": "auto_fire_toggle"},
			{"type": "free_dash_toggle"}
		],
		"image": "res://assets/tilesheet/healthupgrade.png"
	},

	{
		"effects": [
			{"type": "bullet_count", "value": 20},
			{"type": "bullet_spread", "value": 20}
		],
		"image": "res://assets/tilesheet/healthupgrade.png"
	}
]

func _ready():
	await get_tree().process_frame
	open_shop()

func open_shop():

	visible = true
	get_tree().paused = true

	for c in container.get_children():
		c.queue_free()

	var picks = upgrades.duplicate()
	picks.shuffle()

	for i in range(min(3, picks.size())):

		var card = card_scene.instantiate()

		card.data = picks[i]
		card.shop = self

		container.add_child(card)

func on_card_picked(card):

	for c in container.get_children():
		if c != card:
			c.queue_free()

	visible = false
	get_tree().paused = false

	if state:
		state.save_to_player()
	GlobalVaribles.ballance()
	await get_tree().create_timer(0.2).timeout
	
	
	get_tree().change_scene_to_file("res://Scenes/game_loop/map_generator.tscn")
	
