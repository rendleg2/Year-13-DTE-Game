extends Node

var room_grid = []
var start_coord = Vector2i.ZERO
var end_coord = Vector2i.ZERO
var player_pos = Vector2i.ZERO
var map_loaded = false
var enemy_total = 0

var enemy_stats = {
	"normal": {"damage": 10, "health": 100, "bullets": 1, "spread": 0, "bullet_speed": 200, "firerate": 0.3},
	"shotgun": {"damage": 2, "health": 100, "bullets": 5, "spread": 20, "bullet_speed": 200, "firerate": 0.6}
}


func reset():
	enemy_stats = {
	"normal": {"damage": 10, "health": 100, "bullets": 1, "spread": 0, "bullet_speed": 200, "firerate": 0.3},
	"shotgun": {"damage": 2, "health": 100, "bullets": 5, "spread": 20, "bullet_speed": 200, "firerate": 0.6}
}
	enemy_total = 0
	room_grid = []
	start_coord = Vector2i.ZERO
	end_coord = Vector2i.ZERO
	player_pos = Vector2i.ZERO
	map_loaded = false
