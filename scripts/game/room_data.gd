extends Node2D

var enemy = []
var coords: Vector2i
var door: int
var old = []
var clear = false
var wait = true
# Called when the node enters the scene tree for the first time.
func _ready():
	coords = Vector2i(($"../Floor".local_to_map(Vector2i(global_position.x+16, global_position.y+16))/21))
	print("coords ", coords)
	await get_tree().physics_frame
	door = GlobalVaribles.room_grid[coords.x][coords.y]
	wait = false
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if clear == false and wait == false:
		enemy = []
		for child in get_children():
				if child is CharacterBody2D:
					enemy.append(child)
		if len(enemy) == 0:
			print(old)
			var has_up: bool    = (door & 2) > 0
			var has_down: bool  = (door & 1) > 0
			var has_left: bool  = (door & 4) > 0
			var has_right: bool = (door & 8) > 0
			if has_up:
				for i in range(0, 7):
					$"../Walls".set_cell(Vector2i(coords.x*21+7+i, coords.y*21-1), 6, old[0], 0)
					old.pop_front()
			if has_down:
				for i in range(0, 7):
					$"../Walls".set_cell(Vector2i(coords.x*21+7+i, coords.y*21+20+1), 6, old[0], 0)
					old.pop_front()
			if has_left:
				for i in range(0, 7):
					$"../Walls".set_cell(Vector2i(coords.x*21-1, coords.y*21+7+i), 6, old[0], 0)
					old.pop_front()
			if has_right:
				for i in range(0, 7):
					$"../Walls".set_cell(Vector2i(coords.x*21+20+1, coords.y*21+7+i), 6, old[0], 0)
					old.pop_front()
			old = []
			clear = true


func _on_area_2d_body_entered(body):
	if body.has_method("player") and clear == false and wait == false:
		wait = true
		print(coords)
		print(door)
		var has_up: bool    = (door & 2) > 0
		var has_down: bool  = (door & 1) > 0
		var has_left: bool  = (door & 4) > 0
		var has_right: bool = (door & 8) > 0
		print("Up: ", has_up, " | Down: ", has_down, " | Left: ", has_left, " | Right: ", has_right)
		if has_up:
			for i in range(0, 7):
				old.append($"../Walls".get_cell_atlas_coords(Vector2i(coords.x*21+7+i, coords.y*21-1)))
				$"../Walls".set_cell(Vector2i(coords.x*21+7+i, coords.y*21-1), 6, Vector2i(4, 2), 0)
		if has_down:
			for i in range(0, 7):
				old.append($"../Walls".get_cell_atlas_coords(Vector2i(coords.x*21+7+i, coords.y*21+20+1)))
				$"../Walls".set_cell(Vector2i(coords.x*21+7+i, coords.y*21+20+1), 6, Vector2i(4, 2), 0)
		if has_left:
			for i in range(0, 7):
				old.append($"../Walls".get_cell_atlas_coords(Vector2i(coords.x*21-1, coords.y*21+7+i)))
				$"../Walls".set_cell(Vector2i(coords.x*21-1, coords.y*21+7+i), 6, Vector2i(4, 2), 0)
		if has_right:
			for i in range(0, 7):
				old.append($"../Walls".get_cell_atlas_coords(Vector2i(coords.x*21+20+1, coords.y*21+7+i)))
				$"../Walls".set_cell(Vector2i(coords.x*21+20+1, coords.y*21+7+i), 6, Vector2i(4, 2), 0)
		for child in get_children():
			if child is CharacterBody2D:
				enemy.append(child)
				child.aggro = true
		wait = false


func _on_area_2d_2_body_entered(body):
	pass # Replace with function body.
