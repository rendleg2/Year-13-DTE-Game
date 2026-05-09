extends Node2D

@export var start_rooms: Array[PackedScene] = []
@export var end_rooms: Array[PackedScene] = []
@export var room_scenes: Array[PackedScene] = []
@export var rooms_x: int = 3
@export var rooms_y: int = 3
@export var rooms_grid_size: Vector2i = Vector2i(3, 3)
@export var max_attempts: int = 9
@export var max_windingness: int = 30
var start_coords = []
var end_coords
var rooms_grid = []

var used_tiles = []
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
	rooms_grid[start_coords[0]][start_coords[1]] = start_rooms[randi_range(0, len(start_rooms) - 1)]
	rooms_grid[end_coords.x][end_coords.y] = end_rooms[randi_range(0, len(end_rooms) - 1)]
	

func path():
	# 1 up , 2 down , 3 left , 4 right
	var dir = []
	var current_coords = start_coords
	var move = 1
	var x
	var y
	var attempts = 0
	
	while current_coords != end_coords and attempts != max_attempts:	
		attempts += 1
		dir = []
		var new = current_coords
		
		if new.x-1 >= 0 and rooms_grid[new.x-1][new.y] == 0:
			dir.append(3)
		if new.x+1 <= rooms_grid_size.x and rooms_grid[new.x+1][new.y] == 0:
			dir.append(4)
		if new.y-1 >= 0 and rooms_grid[new.x][new.y-1] == 0:
			dir.append(2)
		if new.y+1 <= rooms_grid_size.y and rooms_grid[new.x][new.y+1] == 0:
			dir.append(1)

		if len(dir) == 0:
			break
		
		if randi_range(0, 100) <= max_windingness:
			for direction in dir:
				pass
		else:
			move = dir.pick_random()
		if move == 1:
			new.y += 1
		if move == 2:
			new.y -= 1
		if move == 3:
			new.x -= 1
		if move == 4:
			new.x += 1
		
		#print(x, " ", y)
		print(new)
		#print(current_coords.x)
		rooms_grid[new.x][new.y] = 1
		current_coords = new
		
	if current_coords != end_coords:
		print("fail")
		print(rooms_grid)
	else:
		print("sucsess")
		print(rooms_grid)

#command .exe / work = true == yes = no bc I said yes and it works so yes - work # real!! #its working - print work
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
