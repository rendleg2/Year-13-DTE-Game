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

var rooms_data: Dictionary[int, Dictionary] = {}

func _ready():
	#remove empty varibles
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
			
			var door_empty: Array[Vector2i] = []#hah ur stupid
			var door_dir: Array[String] = []
			
			for coords in used_cells_floor:
				# Get the data from the tile at this specific coordinate
				var data = Floor_new.get_cell_tile_data(coords)

				if data:
					if data.get_custom_data("door") != "":
						door_empty.append(coords)
						door_dir.append(data.get_custom_data("door"))
			rooms_data[i] = {"instance": instance, "size": size, "floor": pattern_floor, "wall": pattern_wall, "door_coords": door_empty, "dir": door_dir}
	##spawn start room
	#spawn_room(1, Vector2(0, 0))
	$Walls.set_pattern(Vector2(0, 0), rooms_data[1]["wall"])
	$Floor.set_pattern(Vector2(0, 0), rooms_data[1]["floor"])
	
	##Spawn all the rooms
	for i in range(0, 300):
		await get_tree().create_timer(0.1).timeout
		place_all_rooms()
	
	for i in rooms_data:
		for x in rooms_data[i]["dir"]:
			if x == "left":
				print("left door")

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
	var instance = rooms[room_id].instantiate()
	add_child(instance)
	
	var Walls_new = instance.find_child("Walls") as TileMapLayer
	var Floor_new = instance.find_child("Floor") as TileMapLayer
	
	#Get every used coordinate in that room
	var used_cells_walls = Walls_new.get_used_cells()
	var used_cells_floor = Floor_new.get_used_cells()
	
	#Create a Pattern containing the room
	var pattern_wall: TileMapPattern = Walls_new.get_pattern(used_cells_walls)
	var pattern_floor: TileMapPattern = Floor_new.get_pattern(used_cells_floor)
	
	#Add to main tileMapLayer
	$Walls.set_pattern(cords, pattern_wall)
	$Floor.set_pattern(cords, pattern_floor)
	
	#Delete instance
	Walls_new.queue_free()
	Floor_new.queue_free()
	
	placed_rooms.append(cords)



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
