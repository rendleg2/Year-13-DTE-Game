extends Node2D#hah ur stupid
var placed_rooms = []
@export var rooms: Dictionary[int, PackedScene] = {
	1: null,
	2: null,
	3: null,
	4: null,
	5: null,
	6: null,
	7: null,
	8: null,
	9: null,
	10: null,
	11: null,
	12: null,
	13: null,
	14: null,
	15: null
	}

var rooms_data: Dictionary[int, Dictionary] = {
	0: 
		{
		"instance": null, 
		"size": Vector2i.ZERO, 
		"floor_pattern": null, 
		"wall_pattern": null, 
		"door_coords_left": [Vector2i.ZERO, Vector2i.ZERO], 
		"door_coords_right": [Vector2i.ZERO, Vector2i.ZERO], 
		"door_coords_down": [Vector2i.ZERO, Vector2i.ZERO], 
		"door_coords_up": [Vector2i.ZERO, Vector2i.ZERO], 
		},
	}



func _ready():
	print("""
	PLAN:
	Place spawn room
	placedrooms = [[cords, id, free doors], [cords, id, free doors]]
	go through list, 
	select first room, 
	first door cord, 
	find room that fits
	place room
	delete free door thats nolonger free, if free door empty, delete the hole nested list
	move on
	
	Posiblititys, precalculate what rooms can connect to what

	""")
	##Create rooms_data
	for i in range(1, rooms.size()+1):
		if rooms[i] == null:
			rooms.erase(i)
		else:
			var instance = rooms[i].instantiate()
			
			var Floor_new = instance.find_child("Floor") as TileMapLayer
			var Walls_new = instance.find_child("Walls") as TileMapLayer
			
			var used_cells_walls = Walls_new.get_used_cells()
			var used_cells_floor = Floor_new.get_used_cells()
			
			#Create a Pattern containing the room
			var pattern_wall: TileMapPattern = Walls_new.get_pattern(used_cells_walls)
			var pattern_floor: TileMapPattern = Floor_new.get_pattern(used_cells_floor)
			var size = pattern_floor.get_size()
			# Get all coordinates that actually have a tile on them
			
			var door_empty_left: Array[Vector2i] = []
			var door_empty_right: Array[Vector2i] = []
			var door_empty_down: Array[Vector2i] = []
			var door_empty_up: Array[Vector2i] = []
			
			for coords in used_cells_floor:
				# Get the data from the tile at this specific coordinate
				var data = Floor_new.get_cell_tile_data(coords)

				if data:
					data = data.get_custom_data("door")
					if data != "":
						if data == "up":
							door_empty_up.append(coords)
						elif data == "down":
							door_empty_down.append(coords)
						elif data == "left":
							door_empty_left.append(coords)
						elif data == "right":
							door_empty_right.append(coords)
						
			rooms_data[i] = {
				"instance": instance,
				"size": size, 
				"floor": pattern_floor, 
				"wall": pattern_wall, 
				"door_coords_left": door_empty_left, 
				"door_empty_right": door_empty_right, 
				"door_empty_down": door_empty_down, 
				"door_empty_up": door_empty_up
				}

	##spawn start room
	spawn_room(1, Vector2(0, 0))
	
	##Spawn all the rooms
	#for i in range(0, 300):
	#	await get_tree().create_timer(0.1).timeout
	#	place_all_rooms()
	place_all_rooms()

func place_all_rooms():
	var results = find_unused_doors()
	var door_empty= results[0]
	var door_dir = results[1]
	
	
	for i in range(0, len(door_empty)):
		# need code to select room
		var instance = rooms[1].instantiate().find_child("Floor") as TileMapLayer
		var used_cells_floor = instance.get_used_cells()
		var size = instance.get_pattern(used_cells_floor).get_size()
		if door_dir[i] == "right":
			
			for x in rooms_data:
				print(x)
				for y in rooms_data[x]["door_coords_left"]:
					print(y, "y")
					print(Vector2i(y.x+size.x, y.y), "y")
					print(placed_rooms)
					print("door ", Vector2i(door_empty[i].x+1, door_empty[i].y))
					if Vector2i(y.x+size.x, y.y) == Vector2i(door_empty[i].x+1, door_empty[i].y):
						print("work")

			## for finding door matching, use room_data + size of room, for placing room, use global door cords
						#spawn room on west side
						spawn_room(1, Vector2(door_empty[i].x+1, door_empty[i].y-(size.x/2)))

						#remove the unused door tile
						$Floor.set_cell(Vector2i(door_empty[i].x, door_empty[i].y), 0, Vector2i(1, 1))
						$Floor.set_cell(Vector2i(door_empty[i].x+1, door_empty[i].y), 0, Vector2i(1, 1))
		
		elif door_dir[i] == "up":
			
			#spawn room on west side
			spawn_room(1, Vector2(door_empty[i].x-(size.x/2), door_empty[i].y-(size.x)))

			#remove the unused door tile
			$Floor.set_cell(Vector2i(door_empty[i].x, door_empty[i].y), 0, Vector2i(1, 1))
			$Floor.set_cell(Vector2i(door_empty[i].x, door_empty[i].y-1), 0, Vector2i(1, 1))
			
		elif door_dir[i] == "down":
			
			#spawn room on west side
			spawn_room(1, Vector2(door_empty[i].x-(size.x/2), door_empty[i].y+1))

			#remove the unused door tile
			$Floor.set_cell(Vector2i(door_empty[i].x, door_empty[i].y), 0, Vector2i(1, 1))
			$Floor.set_cell(Vector2i(door_empty[i].x, door_empty[i].y+1), 0, Vector2i(1, 1))
		
		elif door_dir[i] == "left":
			
			#spawn room on west side
			spawn_room(1, Vector2(door_empty[i].x-(size.x), door_empty[i].y-(size.x/2)))

			#remove the unused door tile
			$Floor.set_cell(Vector2i(door_empty[i].x, door_empty[i].y), 0, Vector2i(1, 1))
			$Floor.set_cell(Vector2i(door_empty[i].x-1, door_empty[i].y), 0, Vector2i(1, 1))
		instance.queue_free()

func spawn_room(room_id, cords):
	#Add to main tileMapLayer
	$Walls.set_pattern(cords, rooms_data[room_id]["wall"])
	$Floor.set_pattern(cords, rooms_data[room_id]["floor"])

	placed_rooms.append(cords)
	placed_rooms.append(room_id) ## delete when door gone

func find_unused_doors():
	var door_empty: Array[Vector2i] = []
	var door_dir: Array[String] = []
	# Get all coordinates that actually have a tile on them
	var used_cells = $Floor.get_used_cells() 
	
	for coords in used_cells:
		# Get the data from the tile at this specific coordinate
		var data = $Floor.get_cell_tile_data(coords)
		if data:
			if data.get_custom_data("door") != "":
				door_empty.append(coords)
				door_dir.append(data.get_custom_data("door"))
	return [door_empty, door_dir]
