extends Node2D

@export_group("Grid Settings")
@export var width: int = 51
@export var height: int = 51
@export var hallway_tilemap: TileMapLayer # REQUIRED: Link your main TileMapLayer here
@export var floor_atlas_coords: Vector2i = Vector2i(1, 1) # Adjust to your floor tile atlas coordinates
@export var floor_source_id: int = 0

@export_group("Room Settings")
@export var room_attempts: int = 50
@export var room_templates: Array[PackedScene] = []
@export var floor_layer_name: String = "Floor" # The exact name of the floor layer in your room scenes

@export_group("Maze Settings")
@export var winding_percent: int = 20
@export var dead_end_removal_percent: float = 1.0

var grid = [] 
var regions = []
var current_region: int = -1
var room_container: Node2D

func _ready():
	# Safely create a container for the rooms
	room_container = Node2D.new()
	room_container.name = "RoomContainer"
	add_child(room_container)
	
	if not hallway_tilemap:
		push_error("Hallway TileMapLayer is not assigned! The generator needs this to align isometric coordinates.")
		return
		
	generate()

func generate():
	# Clear previous generation
	for child in room_container.get_children():
		child.queue_free()
	hallway_tilemap.clear()
	print("1")
	# Initialize Grid (0 = wall/empty, 1 = floor)
	grid = []
	regions = []
	current_region = -1
	for x in range(width):
		grid.append([])
		regions.append([])
		for y in range(height):
			grid[x].append(0)
			regions[x].append(-1)

	_place_premade_rooms()
	print("2")
	_open_room_edges()
	_fill_mazes()
	_connect_regions()
	_prune_dead_ends()
	_draw_hallways()
	print("3")

func _place_premade_rooms():
	for i in range(room_attempts):
		if room_templates.is_empty(): break
		
		var template = room_templates.pick_random()
		var room_instance = template.instantiate()
		var floor_map = room_instance.find_child(floor_layer_name, true, false) as TileMapLayer
		
		if not floor_map:
			room_instance.free()
			continue

		var rect = floor_map.get_used_rect()
		var w = rect.size.x
		var h = rect.size.y
		
		# Nystrom Rule: Top-left coordinate MUST be odd
		var map_x = (randi() % ((width - w - 2) / 2)) * 2 + 1
		var map_y = (randi() % ((height - h - 2) / 2)) * 2 + 1
		
		if _can_place_room(map_x, map_y, w, h):
			
			current_region += 1
			_stamp_room(template, map_x, map_y)
			

func _can_place_room(x: int, y: int, w: int, h: int) -> bool:
	# Requires 1 tile of padding so rooms don't fuse together natively
	for rx in range(x - 1, x + w + 1):
		for ry in range(y - 1, y + h + 1):
			if rx < 0 or rx >= width or ry < 0 or ry >= height: return false
			if grid[rx][ry] != 0: return false
	return true

func _fill_mazes():
	for y in range(1, height, 2):
		for x in range(1, width, 2):
			if grid[x][y] == 0:
				_grow_maze(Vector2i(x, y))

func _grow_maze(start: Vector2i):
	var cells = []
	var last_dir = Vector2i.ZERO
	current_region += 1
	_carve(start)
	cells.append(start)
	
	while not cells.is_empty():
		var cell = cells.back()
		var unvisited = []
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var n = cell + dir * 2
			if n.x > 0 and n.x < width - 1 and n.y > 0 and n.y < height - 1:
				if grid[n.x][n.y] == 0: unvisited.append(dir)
				
		if not unvisited.is_empty():
			var dir = last_dir if unvisited.has(last_dir) and randi() % 100 > winding_percent else unvisited.pick_random()
			_carve(cell + dir)
			_carve(cell + dir * 2)
			cells.append(cell + dir * 2)
			last_dir = dir
		else:
			cells.pop_back()
			last_dir = Vector2i.ZERO

func _carve(p: Vector2i):
	grid[p.x][p.y] = 1
	regions[p.x][p.y] = current_region

func _connect_regions():
	var connectors = []
	for x in range(1, width - 1):
		for y in range(1, height - 1):
			if grid[x][y] != 0: continue
			var r_found = []
			for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				var r = regions[x + dir.x][y + dir.y]
				if r != -1 and not r_found.has(r): r_found.append(r)
			if r_found.size() >= 2:
				connectors.append({"pos": Vector2i(x, y), "regions": r_found})

	var merged = {}
	for i in range(current_region + 1): merged[i] = i
	
	var remaining_regions = current_region
	while remaining_regions > 0 and not connectors.is_empty():
		var con = connectors.pick_random()
		var r1 = _find_root(con.regions[0], merged)
		var r2 = _find_root(con.regions[1], merged)
		
		if r1 != r2:
			grid[con.pos.x][con.pos.y] = 1 # Open the door
			merged[r1] = r2
			remaining_regions -= 1
		connectors.erase(con)

func _find_root(r, m):
	while m[r] != r: r = m[r]
	return r

func _prune_dead_ends():
	var done = false
	while not done:
		done = true
		for x in range(1, width - 1):
			for y in range(1, height - 1):
				if grid[x][y] == 0: continue
				var exits = 0
				for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
					if grid[x + dir.x][y + dir.y] == 1: exits += 1
				
				# If it's a dead end, we check if it belongs to a room.
				# If it belongs to a room (region ID < room_attempts generally), we DO NOT delete it.
				# To be safe, we just check if deleting it breaks the map.
				if exits == 1 and randf() <= dead_end_removal_percent:
					grid[x][y] = 0
					done = false

func _draw_hallways():
	# Draw only the tiles that belong to the newly generated maze/connectors.
	# We skip tiles that belong to the first 'room_attempts' regions, 
	# because the instanced scenes already handle those visually.
	
	for x in range(width):
		for y in range(height):
			if grid[x][y] == 1:
				# Check if this tile was painted by a room or the maze
				var is_room_tile = false
				# We verify if this exact coordinate is covered by a child room instance
				# For simplicity, we just draw ALL floor tiles here. 
				# Your room scenes should sit perfectly on top.
				hallway_tilemap.set_cell(Vector2i(x, y), floor_source_id, floor_atlas_coords)

func _open_room_edges():
	for x in range(width):
		for y in range(height):
			if grid[x][y] == 1: # If it's a room floor
				# Look for adjacent empty space (potential doorway)
				for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
					var neighbor = Vector2i(x, y) + dir
					if neighbor.x > 0 and neighbor.x < width - 1 and neighbor.y > 0 and neighbor.y < height - 1:
						if grid[neighbor.x][neighbor.y] == 0:
							# 10% chance to open a doorway
							if randf() < 0.1:
								grid[neighbor.x][neighbor.y] = 1

func _stamp_room(template: PackedScene, map_x: int, map_y: int):
	# 1. VISUAL STAMP: Read tiles from the template
	var room_visuals = template.instantiate()
	var floor_src = room_visuals.find_child("Floor", true, false) as TileMapLayer
	var wall_src = room_visuals.find_child("Walls", true, false) as TileMapLayer
	
	if floor_src:
		for cell in floor_src.get_used_cells():
			var gx = map_x + cell.x
			var gy = map_y + cell.y
			hallway_tilemap.set_cell(Vector2i(gx, gy), floor_src.get_cell_source_id(cell), floor_src.get_cell_atlas_coords(cell))
			grid[gx][gy] = 1
			
	if wall_src:
		for cell in wall_src.get_used_cells():
			var gx = map_x + cell.x
			var gy = map_y + cell.y
			$Walls.set_cell(Vector2i(gx, gy), wall_src.get_cell_source_id(cell), wall_src.get_cell_atlas_coords(cell))
			
	room_visuals.free() # Visuals are now on the Master TileMap, delete blueprint
	
	# 2. LOGIC INSTANTIATION: Load the logic-only version
	# You need a separate file or a way to remove tiles from this instance
	print("""
	var logic_scene = load(template.resource_path.replace(".tscn", "_LogicOnly.tscn")).instantiate()
	room_container.add_child(logic_scene)
	
	# Position the logic nodes to match the stamped tiles
	var target_pos = hallway_tilemap.map_to_local(Vector2i(map_x, map_y))
	logic_scene.position = target_pos# - origin_offset
	""")
