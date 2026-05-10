extends Node2D

@export var start_rooms: Array[PackedScene] = []
@export var end_rooms: Array[PackedScene] = []
@export var room_scenes: Array[PackedScene] = []
@export var rooms_grid_size_start: Vector2i = Vector2i(3, 3)
@export var max_attempts: int = 9
@export var max_windingness: int = 30
@export var room_size: int = 10

var bitwise = {
		Vector2i.DOWN: 1,
		Vector2i.UP: 2,
		Vector2i.LEFT: 4,
		Vector2i.RIGHT: 8
	}

var start_coords = Vector2i.ZERO
var end_coords = Vector2i.ZERO
var rooms_grid = []

@onready var rooms_grid_size = rooms_grid_size_start

var used_tiles = []

var path_taken = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(0, rooms_grid_size.x):
		rooms_grid.append([])
		for y in range(0, rooms_grid_size.y):
			rooms_grid[x].append(-1)
	
	rooms_grid_size.x -= 1
	rooms_grid_size.y -= 1
	
	var x = randi_range(0, rooms_grid_size.x)
	var y = 0
	match x:
		0, rooms_grid_size.x:
			y = randi_range(0, rooms_grid_size.y)
		_:
			y = randi_range(0,1)
			if y == 1:
				y = rooms_grid_size.y
				
	print(x, " ", y, " start")
	
	start_coords = Vector2i(x, y)
	x = rooms_grid_size.x - x
	y = rooms_grid_size.y - y
	print(x, " ", y, " end")
	end_coords = Vector2i(x, y)
	
	rooms_grid[start_coords.x][start_coords.y] = 0
	rooms_grid[end_coords.x][end_coords.y] = -1
	#create initial path
	path_bitwise(start_coords, end_coords, max_attempts)
	#place the rooms onto playable area
	await off_shoot_rooms()
	place_rooms_bitwise()
	#place_rooms()
	stamp_room(0, Vector2i(start_coords.x*room_size, start_coords.y*room_size), 1)
	stamp_room(0, Vector2i(end_coords.x*room_size, end_coords.y*room_size), 2)
	#rooms_grid[start_coords.x][start_coords.y] = start_rooms[randi_range(0, len(start_rooms) - 1)]
	#rooms_grid[end_coords.x][end_coords.y] = end_rooms[randi_range(0, len(end_rooms) - 1)]
	$Player.global_position = $Floor.map_to_local(Vector2i(start_coords.x*room_size+5, start_coords.y*room_size+5))
	print($Player.position)

func off_shoot_rooms():
	var dir = []
	var offshoot_count = 0
	var offshoot_points = []
	var skip = 0
	for x in range(0, len(rooms_grid)):
		for y in range(0, len(rooms_grid[x])):
			dir = []
			if rooms_grid[x][y] != 0 and rooms_grid[x][y] != -1:
				skip -= 1
				print(rooms_grid[x][y], "rooms place?")
				if x-1 >= 0 and rooms_grid[x-1][y] == -1:
					dir.append(Vector2i.LEFT)
				if x+1 <= rooms_grid_size.x and rooms_grid[x+1][y] == -1:
					dir.append(Vector2i.RIGHT)
				if y-1 >= 0 and rooms_grid[x][y-1] == -1:
					dir.append(Vector2i.UP)
				if y+1 <= rooms_grid_size.y and rooms_grid[x][y+1] == -1:
					dir.append(Vector2i.DOWN)
				if len(dir) > 0 and skip < 1:
					skip = randi_range(5, 10)
					offshoot_count += 1
					offshoot_points.append([Vector2i(x, y), dir.pick_random()])
				else:
					skip-=1
					
	for i in range(0,len(offshoot_points)):
		print(offshoot_points)
		print(offshoot_points[i][0], " <> ", rooms_grid[offshoot_points[i][0].x][offshoot_points[i][0].y])
		rooms_grid[offshoot_points[i][0].x][offshoot_points[i][0].y] += bitwise[offshoot_points[i][1]]
		path_bitwise(Vector2i(offshoot_points[i][0].x, offshoot_points[i][0].y), null, 5)
		

func place_rooms_bitwise():
	var possible_rooms = []
	for x in range(0, rooms_grid_size.x+1):
		for y in range(0, rooms_grid_size.y+1):
			possible_rooms = []
			if rooms_grid[x][y] != 0 and rooms_grid[x][y] != -1:
				for i in range(0, len(room_scenes)):
					
					var name:String = room_scenes[i].resource_path.get_file().get_basename()
					print(name, " looking for> ", rooms_grid[x][y])
					print(i, " <> ", name.contains(str(rooms_grid[x][y])))
					if name.to_int() != rooms_grid[x][y]:
						continue
					else:
						possible_rooms.append(i)
			if len(possible_rooms)>0:
				print(possible_rooms, " possible_rooms > ", rooms_grid[x][y])
				stamp_room(possible_rooms.pick_random(), Vector2i(x*room_size, y*room_size), 0)
			elif rooms_grid[x][y] != 0 and rooms_grid[x][y] != -1:
				print("FAIL TO FIND ROOM ", rooms_grid[x][y])

func place_rooms():
	var selected_room
	for x in range(0, rooms_grid_size.x+1):
		for y in range(0, rooms_grid_size.y+1):
			if len(rooms_grid[x][y]) > 0 and rooms_grid[x][y] != [0]:
				#print(" new room ")
				#$Floor.set_cell(Vector2i(x, y), 0, Vector2i(1, 1), 0)
				for i in range(0, len(room_scenes)):
					selected_room = "error"
					var Match =true
					var name:String = room_scenes[i].resource_path.get_file().get_basename()
					#print(name, " looking for> ", rooms_grid[x][y])
					for z in rooms_grid[x][y]:
						#print(z, " <> ", name.contains(str(z)))
						if name.contains(str(z)) != true:
							Match = false
							break
						else:
							name = name.erase(name.find(str(z)), str(z).length())
						
					if Match:
						print(name)
						for check in [Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT]:
							if name.contains(str(check)) == true:
								Match = false
					if Match:
						selected_room = i
						break
				stamp_room(selected_room, Vector2i(x*room_size, y*room_size), 0)



func stamp_room(id, coord, type):
	#print(coord)
	var room
	if type == 0:
		room = room_scenes[id].instantiate()
	elif type == 1:
		room = start_rooms[id].instantiate()
	elif type == 2:
		room = end_rooms[id].instantiate()
	var floor: TileMapLayer = room.get_child(0)
	var wall: TileMapLayer = room.get_child(1)
	var room_data: Node2D = room.get_child(2)
	floor.get_pattern(floor.get_used_cells())
	wall.get_pattern(wall.get_used_cells())
	room.remove_child(room_data)
	room_data.global_position = $Floor.map_to_local(Vector2i(coord)-Vector2i.RIGHT)
	$all_room_data.get_parent().add_child(room_data)
	$Floor.set_pattern(coord, floor.get_pattern(floor.get_used_cells()))
	$Walls.set_pattern(coord, wall.get_pattern(wall.get_used_cells()))
	room.queue_free()

func path(start_coords_2, end_coords_2, max_attempts_2):
	# 1 up , 2 down , 3 left , 4 right
	var dir = []
	var current_coords = start_coords_2
	var last_coords = Vector2i.ZERO
	var move = Vector2i(0,0)
	var last_move = Vector2i.ZERO
	var x
	var y
	var attempts = -1
	while current_coords != end_coords_2 and attempts != max_attempts_2:	
		attempts += 1
		dir = []
		var new = current_coords
		
		#possible directons
		if new.x-1 >= 0 and rooms_grid[new.x-1][new.y] == []:
			dir.append(Vector2i.LEFT)
		if new.x+1 <= rooms_grid_size.x and rooms_grid[new.x+1][new.y] == []:
			dir.append(Vector2i.RIGHT)
		if new.y-1 >= 0 and rooms_grid[new.x][new.y-1] == []:
			dir.append(Vector2i.UP)
		if new.y+1 <= rooms_grid_size.y and rooms_grid[new.x][new.y+1] == []:
			dir.append(Vector2i.DOWN)

		#Backtracking
		if end_coords_2 == null and len(dir) == 0:
			print("broke: ", attempts)
			break
		elif len(dir) == 0:
			if path_taken.size() == 0:
				print("Pathfinder stuck at start, no route possible!")
				break
			rooms_grid[new.x][new.y] = [0]
			current_coords -= path_taken[-1][1]
			path_taken.pop_back()
			new = current_coords
		
		else:
			#print(move)
			if attempts >0:
				if move == Vector2i.UP or move == Vector2i.DOWN:
					last_move=-move
				else:
					last_move=-move
				last_coords = current_coords
			#random or best move?
			if (randi_range(0, 100) >= max_windingness or len(dir) == 2) and end_coords_2 != null:
				move = dir.pick_random()
				for direction in dir:
					if (current_coords + direction).distance_to(end_coords_2) < current_coords.distance_to(end_coords_2):
						move = direction
			else:
				move = dir.pick_random()
			
			new += move
			
			#saving the move
			if attempts > 0:
				path_taken.append([last_move,move])
				#print(current_coords.x)
				rooms_grid[last_coords.x][last_coords.y] = [last_move, move]
			else:
				last_move=-move

			current_coords = new
		#print(new, " ", move)
	
	if current_coords != end_coords_2 and end_coords_2 != null:
		#print(rooms_grid)
		print("fail")
	elif current_coords == end_coords_2:
		#print(rooms_grid)
		print("sucsess")
		#print(path_taken)
	else:
		print("extra path hit end of road")

func path_bitwise(start_coords_2, end_coords_2, max_attempts_2):
	
	var dir = []
	var current_coords = start_coords_2
	var last_coords = Vector2i.ZERO
	var move = Vector2i(0,0)
	var last_move = Vector2i.ZERO
	var x
	var y
	var attempts = -1
	while current_coords != end_coords_2 and attempts != max_attempts_2:	
		attempts += 1
		dir = []
		var new = current_coords
		
		#possible directons
		if new.x-1 >= 0 and rooms_grid[new.x-1][new.y] == -1:
			dir.append(Vector2i.LEFT)
		if new.x+1 <= rooms_grid_size.x and rooms_grid[new.x+1][new.y] == -1:
			dir.append(Vector2i.RIGHT)
		if new.y-1 >= 0 and rooms_grid[new.x][new.y-1] == -1:
			dir.append(Vector2i.UP)
		if new.y+1 <= rooms_grid_size.y and rooms_grid[new.x][new.y+1] == -1:
			dir.append(Vector2i.DOWN)

		#Backtracking
		if end_coords_2 == null and len(dir) == 0:
			print("broke: ", attempts)
			break
		elif len(dir) == 0:
			if path_taken.size() == 0:
				print("Pathfinder stuck at start, no route possible!")
				break
			rooms_grid[new.x][new.y] = 0
			current_coords -= path_taken[-1][1]
			path_taken.pop_back()
			new = current_coords
		
		else:
			#print(move)
			if attempts > 0:
				last_move=-move
				last_coords = current_coords
			#random or best move?
			if (randi_range(0, 100) >= max_windingness or len(dir) == 2) and end_coords_2 != null:
				move = dir.pick_random()
				for direction in dir:
					if (current_coords + direction).distance_to(end_coords_2) < current_coords.distance_to(end_coords_2):
						move = direction
			else:
				move = dir.pick_random()
			
			new += move
			
			#saving the move
			if attempts > 0:
				path_taken.append([last_move,move])
				#print(current_coords.x)
				rooms_grid[last_coords.x][last_coords.y] = bitwise[last_move] + bitwise[move]
			else:
				last_move=-move

			current_coords = new
		#print(new, " ", move)
	
	if current_coords != end_coords_2 and end_coords_2 != null:
		#print(rooms_grid)
		print("fail")
	elif current_coords == end_coords_2:
		#print(rooms_grid)
		print("sucsess")
		#print(path_taken)
	else:
		print("extra path hit end of road")

#command .exe / work = true == yes = no bc I said yes and it works so yes - work # real!! #its working - print work
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
