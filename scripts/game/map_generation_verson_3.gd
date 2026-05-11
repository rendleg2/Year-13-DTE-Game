extends Node2D
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
	Place spawn room  DONE
	placedrooms = [[cords, id, free doors], [cords, id, free doors]]  DONE
	go through list,  DONE
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
				"floor_pattern": pattern_floor, 
				"wall_pattern": pattern_wall, 
				"door_coords_left": door_empty_left, 
				"door_coords_right": door_empty_right, 
				"door_coords_down": door_empty_down, 
				"door_coords_up": door_empty_up
				}

	##spawn start room
	spawn_room(2, Vector2(0, 0))
	
	
			
	
	##Spawn all the rooms
	#for i in range(0, 300):
	#	await get_tree().create_timer(0.1).timeout
	#	place_all_rooms()
	place_all_rooms()

func place_all_rooms():
	var open = find_unused_doors()
	var open_door_coords = open[0]
	var open_door_dir = open[1]
	
	var door_offsets = {
		"right": Vector2i(1, 0),
		"left": Vector2i(-1, 0),
		"up": Vector2i(0, -1),
		"down": Vector2i(0, 1)
	}
	
	var placed_rooms2 = placed_rooms
	for dir in ["left", "right", "up", "down"]:
		for placed_room_selected in range(0, len(placed_rooms2)):
			
			var possible_rooms2 = find_matching_room(placed_room_selected, dir)
			
			#print(find_matching_room(placed_room_selected, dir))
			
			if len(possible_rooms2) != 0:
				print(placed_rooms2)
				spawn_room(possible_rooms2[0], Vector2i(10,10))

func find_matching_room(base_room, base_dir):
	var possible_rooms = []
	
	var opposite_doors = {
		"left": "right",
		"right": "left",
		"up": "down",
		"down": "up"
	}
	#print(base_dir ," START ", base_room)
	for possible_room in range(1, len(rooms_data), 1):
		for door in range(0, len(rooms_data[possible_room][str("door_coords_", opposite_doors[base_dir])]), 1):
			
			var size = rooms_data[possible_room]["size"]

			#print("""
			#TEST:
			#
			#""", rooms_data[possible_room][str("door_coords_", opposite_doors[base_dir])][door].x + size.x if base_dir == "right" else -size.x, "==", rooms_data[placed_rooms[base_room][1]][str("door_coords_", base_dir)][door].x)
			
			if rooms_data[possible_room][str("door_coords_", opposite_doors[base_dir])][door].x + size.x if base_dir == "right" else -size.x  == rooms_data[placed_rooms[base_room][1]][str("door_coords_", base_dir)][door].x:
			#	print(" hi s")
				possible_rooms.append(possible_room)
				
	return possible_rooms

func spawn_room(room_id, cords):
	#Add to main tileMapLayer
	$Walls.set_pattern(cords, rooms_data[room_id]["wall_pattern"])
	$Floor.set_pattern(cords, rooms_data[room_id]["floor_pattern"])
	var unused_doors = []
	for x in ["left", "right", "up", "down"]:
		for i in range(0, len(rooms_data[room_id]["door_coords_" + x])):
			unused_doors.append(x)
	#unused_doors.append(5 if 1 == 1 else 2)

	placed_rooms.append([cords, room_id, unused_doors])

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
