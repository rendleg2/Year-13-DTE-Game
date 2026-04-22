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
	#for i in range(0, 3):
	#	await get_tree().create_timer(0.1).timeout
	#	place_all_rooms()
	place_all_rooms()

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


func place_all_rooms():
	# Dictionary to map opposing doors for easy matching
	var opposite_doors = {
		"left": "right",
		"right": "left",
		"up": "down",
		"down": "up"
	}

	# Dictionary to define the coordinate offset to connect two doors
	# e.g., connecting a 'right' door means moving 1 tile to the right (+1, 0)
	var door_offsets = {
		"right": Vector2i(1, 0),
		"left": Vector2i(-1, 0),
		"up": Vector2i(0, -1),
		"down": Vector2i(0, 1)
	}
	
	# We will loop through rooms we've already placed to branch off them
	for placed_room in placed_rooms:
		print(placed_rooms)
		if len(placed_rooms) > 700:
			print(len(placed_rooms))
			break
		var room_pos = placed_room[0] # Global position where room was placed
		var room_id = placed_room[1]  
		var open_doors = placed_room[2] # Array of un-connected door directions
		
		# Let's say we want to attach a standard room (ID 1)
		var next_room_id = randi_range(1,2)
		
		# Iterate backwards so we can safely remove doors from the array as we use them
		for z in range(open_doors.size() - 1, -1, -1):
			var current_door_dir = open_doors[z]
			var required_matching_door = opposite_doors[current_door_dir]
			
			# 1. Find the local coordinate of the door we are trying to branch OUT of
			# Note: Assuming index [0] for simplicity, you might want to pick randomly if a room has multiple "left" doors
			var local_exit_door = rooms_data[room_id]["door_coords_" + current_door_dir][0]
			var global_exit_door = room_pos + Vector2(local_exit_door)
			
			# 2. Calculate exactly where the NEW door needs to be to connect properly
			var target_new_door_global = global_exit_door + Vector2(door_offsets[current_door_dir])
			
			# 3. Check if the next room actually has the required matching door
			var next_room_doors = rooms_data[next_room_id]["door_coords_" + required_matching_door]
			if next_room_doors.size() > 0:
				# 4. Grab the local coordinate of the door on the NEW room
				var new_room_local_entrance = next_room_doors[0]
				
				# 5. THE MAGIC FORMULA: Where does the new room's top-left corner need to go?
				var new_room_spawn_pos = target_new_door_global - Vector2(new_room_local_entrance)
				
				# Spawn the room!
				spawn_room(next_room_id, new_room_spawn_pos)
				
				# Remove the door we just used from the current room's open list
				open_doors.remove_at(z)
					
				# Remove the used door from the CURRENT room's array so we don't branch from it again
				placed_rooms[z][2].remove_at(z)
					
				# --- NEW CODE: FIX THE GHOST DOOR ---
				# The room we just spawned is now the last item in placed_rooms: placed_rooms[-1]
				# We need to find the entrance door it used and remove it from its 'unused' list.
				var new_room_unused_doors = placed_rooms[-1][2]
				var entrance_door_index = new_room_unused_doors.find(needed_door_dir)
				
				if entrance_door_index != -1:
					new_room_unused_doors.remove_at(entrance_door_index)
					# ------------------------------------
					
					# Break out of the 'x' loop so we don't spawn 50 rooms on the same door
					break
				# Optionally: Overwrite the door tiles with regular floor tiles here
				$Floor.set_cell(global_exit_door, 0, Vector2i(1, 1))
				$Floor.set_cell(target_new_door_global, 0, Vector2i(1, 1))
				break

func place_all_rooms2():
	
					## for finding door matching, use room_data + size of room, for placing room, use global door cords
	for i in len(placed_rooms):
		for z in len(placed_rooms[i][2]):
			#print(i, " ", placed_rooms[i][2][z])

			# need code to select room
			var instance = rooms[1].instantiate().find_child("Floor") as TileMapLayer
			var used_cells_floor = instance.get_used_cells()
			var size = instance.get_pattern(used_cells_floor).get_size() 
			if placed_rooms[i][2][z] == "left":
				for x in rooms_data:
					for open_door in rooms_data[x]["door_coords_right"]:
						print("open_door ", open_door)

						#print(placed_rooms) 
						print("matching door ", Vector2i(rooms_data[placed_rooms[i][1]]["door_coords_left"][0].x+size.x-1, rooms_data[placed_rooms[i][1]]["door_coords_left"][0].y))
						
						if Vector2i(open_door.x, open_door.y) == Vector2i(rooms_data[placed_rooms[i][1]]["door_coords_left"][0].x+size.x-1, rooms_data[placed_rooms[i][1]]["door_coords_left"][0].y):
							print("work")


							#spawn room on left side
							spawn_room(1, Vector2i(rooms_data[placed_rooms[i][1]]["door_coords_left"][0].x+size.x, rooms_data[placed_rooms[i][1]]["door_coords_left"][0].y - (size.y/2)))

							#remove the unused door tile 
							$Floor.set_cell(Vector2i(rooms_data[placed_rooms[i][1]]["door_coords_left"][0].x+size.x, rooms_data[placed_rooms[i][1]]["door_coords_left"][0].y), 0, Vector2i(1, 1))
							$Floor.set_cell(Vector2i(rooms_data[placed_rooms[i][1]]["door_coords_left"][0].x+size.x-1, rooms_data[placed_rooms[i][1]]["door_coords_left"][0].y), 0, Vector2i(1, 1))
							print(rooms_data[x]["door_coords_right"])
							print(rooms_data[placed_rooms[i][1]]["door_coords_right"][0])
							
							
							placed_rooms[i][2][ rooms_data[x]["door_coords_right"].rfind(Vector2i(rooms_data[ placed_rooms[i][1] ]["door_coords_right"][0].x, rooms_data[ placed_rooms[i][1] ] ["door_coords_right"][0].y))+len(rooms_data[x]["door_coords_left"])] = null
							placed_rooms[i+1][2][rooms_data[x]["door_coords_left"].rfind(Vector2i(rooms_data[placed_rooms[i][1]]["door_coords_left"][0].x, rooms_data[placed_rooms[i][1]]["door_coords_left"][0].y))] = null
							
							## replace right with left and left with right
