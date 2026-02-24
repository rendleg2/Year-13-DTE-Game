extends TextureButton

func _ready():
	self.pressed.connect(_on_button_pressed)

func _on_button_pressed():
	var player = _find_player()
	
	if player != null:
		player.speed *= 2
		player.free_dash = true

		print("*Button Click Noises*!")
		self.disabled = true
	else:
		print("SOME TING WONG")

func _find_player():
	for node in get_tree().get_nodes_in_group("Cards"):
		return node
	return null
