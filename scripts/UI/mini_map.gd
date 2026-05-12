extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	var rooms_grid = GlobalVaribles.room_grid
	while GlobalVaribles.map_loaded == false:
		await get_tree().create_timer(1.0).timeout
	rooms_grid = GlobalVaribles.room_grid
	place_rooms_bitwise(Vector2i(len(rooms_grid), len(rooms_grid[0])), rooms_grid)
	$TileMapLayer.set_cell(GlobalVaribles.start_coord, 0, Vector2i(0, 0))
	$TileMapLayer.set_cell(GlobalVaribles.end_coord, 0, Vector2i(0, 0))

func place_rooms_bitwise(room_grid_size:Vector2i, rooms_grid):
	var possible_rooms = []
	for x in range(0, room_grid_size.x):
		for y in range(0, room_grid_size.y):
			possible_rooms = []
			if rooms_grid[x][y] != 0 and rooms_grid[x][y] != -1:
				$TileMapLayer.set_cell(Vector2i(x, y), 0, Vector2i(rooms_grid[x][y], 0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$marker.position = $TileMapLayer.map_to_local(GlobalVaribles.player_pos)
