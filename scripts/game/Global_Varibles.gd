extends Node

var room_grid: Array
var start_coord: Vector2i
var end_coord: Vector2i
var player_pos: Vector2i
var map_loaded: bool
var enemy_total: int

var enemy_stats: Dictionary
var level: int


func reset():
	enemy_stats = {
	"normal": {"damage": 10, "health": 100, "bullets": 1, "spread": 0, "bullet_speed": 200, "firerate": 0.3},
	"shotgun": {"damage": 2, "health": 100, "bullets": 5, "spread": 20, "bullet_speed": 200, "firerate": 0.6}
}
	level = 0
	enemy_total = 0
	room_grid = []
	start_coord = Vector2i.ZERO
	end_coord = Vector2i.ZERO
	player_pos = Vector2i.ZERO
	map_loaded = false

func ballance():
	for i in enemy_stats.keys():
		enemy_stats[i]["health"] += (int(Global.bullet_count)*int(Global.bullet_damage))/ (int((Global.bullet_spread+1)/Global.bullet_count) if Global.bullet_spread > 0 else 1)
