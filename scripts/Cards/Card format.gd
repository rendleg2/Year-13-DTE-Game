extends TextureButton # Pretty self explanitory

func _ready():
	self.pressed.connect(Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	var player_stats = _find_player()
	if player_stats != null:
		var old = player_stats.speed # Change speed to what stat your changing 
		player_stats.speed *= 2 # Where you give the buffs 
		print("Speed increased from ", old," ----> ", player_stats.speed)  # player_stats.speed you have to change the speed part to display what you changed
		self.disabled = true  # Stops clicks after first
	else:
		print("Player needs to put in the same scene")

func _find_player() -> Node:
	for node in get_tree().get_nodes_in_group("Cards"):
		return node
	return null
