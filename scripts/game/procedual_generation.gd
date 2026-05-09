extends Node2D

@export var start_rooms: Array[PackedScene] = []
@export var end_rooms: Array[PackedScene] = []
@export var room_scenes: Array[PackedScene] = []
@export var rooms_grid_size_start: Vector2i = Vector2i(3, 3)
@export var max_attempts: int = 9
@export var max_windingness: int = 30
@export var room_size: int = 10
var start_coords = Vector2i.ZERO
var end_coords = Vector2i.ZERO
var rooms_grid = []

@onready var rooms_grid_size = rooms_grid_size_start

var used_tiles = []

signal bake_nav

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	

	for x in range(0, rooms_grid_size.x):
		rooms_grid.append([])
		for y in range(0, rooms_grid_size.y):
			rooms_grid[x].append(0)
	
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
	
	
	
	path()
	place_rooms()
	stamp_room(0, Vector2i(start_coords.x*room_size, start_coords.y*room_size), 1)
	#rooms_grid[start_coords.x][start_coords.y] = start_rooms[randi_range(0, len(start_rooms) - 1)]
	#rooms_grid[end_coords.x][end_coords.y] = end_rooms[randi_range(0, len(end_rooms) - 1)]
	$Player.global_position = $Floor.map_to_local(Vector2i(start_coords.x*room_size+5, start_coords.y*room_size+5))
	print($Player.position)

func place_rooms():
	for x in range(0, rooms_grid_size.x+1):
		for y in range(0, rooms_grid_size.y+1):
			if rooms_grid[x][y] == 1:
				#$Floor.set_cell(Vector2i(x, y), 0, Vector2i(1, 1), 0)
				stamp_room(0, Vector2i(x*room_size, y*room_size), 0)



func stamp_room(id, coord, type):
	print(coord)
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

func path():
	# 1 up , 2 down , 3 left , 4 right
	var dir = []
	var current_coords = start_coords
	var move = Vector2i(0,0)
	var x
	var y
	var attempts = 0
	var path_taken = []
	while current_coords != end_coords and attempts != max_attempts:	
		attempts += 1
		dir = []
		var new = current_coords
		
		if new.x-1 >= 0 and rooms_grid[new.x-1][new.y] == 0:
			dir.append(Vector2i.LEFT)
		if new.x+1 <= rooms_grid_size.x and rooms_grid[new.x+1][new.y] == 0:
			dir.append(Vector2i.RIGHT)
		if new.y-1 >= 0 and rooms_grid[new.x][new.y-1] == 0:
			dir.append(Vector2i.UP)
		if new.y+1 <= rooms_grid_size.y and rooms_grid[new.x][new.y+1] == 0:
			dir.append(Vector2i.DOWN)

		if len(dir) == 0:
			rooms_grid[new.x][new.y] = 2
			current_coords -= path_taken[-1]
			path_taken.pop_back()
			new = current_coords
		
		else:
			if randi_range(0, 100) >= max_windingness or len(dir) == 2:
				move = dir.pick_random()
				for direction in dir:
					if (current_coords + direction).distance_to(end_coords) < current_coords.distance_to(end_coords):
						move = direction
			else:
				move = dir.pick_random()
			
			new += move
		
		
			path_taken.append(move)
			#print(current_coords.x)
			rooms_grid[new.x][new.y] = 1
			#$Floor.set_cell(new, 0, Vector2i(1, 1), 0)
			current_coords = new
		print(new, " ", move)
	
	if current_coords != end_coords:
		print(rooms_grid)
		print("fail")
	else:
		#print(rooms_grid)
		print("sucsess")

#command .exe / work = true == yes = no bc I said yes and it works so yes - work # real!! #its working - print work
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
