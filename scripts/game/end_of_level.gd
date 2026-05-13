extends Area2D


func _on_body_entered(body: Node2D) -> void:
	print(body)
	if body.has_method("player") == true and GlobalVaribles.enemy_total <= 0:
		get_tree().change_scene_to_file(str("res://Scenes/game_loop/shoproom.tscn"))
		print("change")
		GlobalVaribles.level +=1
