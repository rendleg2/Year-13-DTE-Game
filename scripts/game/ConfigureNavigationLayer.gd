extends TileMapLayer
@onready var walls = $"../TestWalls" #rename to actual tilelayer after testing
@onready var objects = $"../TestWalls"

#This script removes the nav layers from floor tiles when the walls or objects are there
#the purpose of this is so enemys dont try to go through walls but can still walk in big open rooms
func _use_tile_data_runtime_update(coords):
	if coords in walls.get_used_cells_by_id(0) or coords in objects.get_used_cells_by_id(1):
		return true
	return false
	
func _tile_data_runtime_update(coords, tile_data):
	if coords in walls.get_used_cells_by_id(0) or coords in objects.get_used_cells_by_id(1):
		tile_data.set_navigation_polygon(0, null)
