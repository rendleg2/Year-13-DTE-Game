extends TextureButton

func _ready():
	self.pressed.connect(Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	var player_stats = _find_player()
	if player_stats != null:
		player_stats.ability_speed *= 1
		player_stats.free_dash = true
		print("Boop! Free dash enabled. Ability speed now: ", player_stats.ability_speed)
		self.disabled = true  # Stops clicks after first
	else:
		print("Player script not found in scene!")

func _find_player() -> Node:
	for node in get_tree().get_nodes_in_group("Cards"):
		return node
	return null
