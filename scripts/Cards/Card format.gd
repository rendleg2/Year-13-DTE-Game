extends TextureButton

func _ready():
	self.pressed.connect(Callable(self, "_on_button_pressed"))

func _on_button_pressed():
	var player_stats = _find_player()
	if player_stats != null: # If i need to explain how this works to anyone that person is gonna no more more
		
		player_stats.speed *= 2  
		
		#player_stats.ability_speed *= 2  
		#player_stats.ability_duration *= 2  
		player_stats.ability_cooldown *= 0
		
		player_stats.bullet_size *= 222^14
		player_stats.bullet_speed *= 2 
		#player_stats.bullet_damage *= 2  
		#player_stats.bullet_range *= 2  
		player_stats.free_dash = true  # This allows you to move while dashing

		self.disabled = true  # allows only 1 click # it if u wana make funny button
		print("Button smack")
	else:
		print("Player needs to put in the same scene")

func _find_player() -> Node:
	var players = get_tree().get_nodes_in_group("Cards")
	if players.size() > 0:
		return players[0]
	return null
