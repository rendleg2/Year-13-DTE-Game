extends Node

var room_grid: Array
var start_coord: Vector2i
var end_coord: Vector2i
var player_pos: Vector2i
var map_loaded: bool
var enemy_total: int
var enemy_movement_speed = 60

var enemy_stats: Dictionary
var level: int
var Difficlty

func reset():
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
	if Difficlty == "easy":
		enemy_stats["normal"]["damage"] += 2
		enemy_stats["normal"]["bullets"] += 0
		enemy_stats["normal"]["spread"] += 0
		enemy_stats["normal"]["movement_speed"] += 2
		enemy_stats["normal"]["bullet_speed"] += 5
		if level < 3:
			enemy_stats["normal"]["firerate"] -= 0.1
			
		enemy_stats["shotgun"]["damage"] += 1
		enemy_stats["shotgun"]["bullets"] += 1
		enemy_stats["shotgun"]["spread"] += 4
		enemy_stats["shotgun"]["movement_speed"] += 2
		enemy_stats["shotgun"]["bullet_speed"] += 5
		if level < 3:
			enemy_stats["shotgun"]["firerate"] -= 0.1
		
		enemy_stats["boss"]["damage"] += 5
		enemy_stats["boss"]["bullets"] += 3
		enemy_stats["boss"]["spread"] += 0
		enemy_stats["boss"]["movement_speed"] += 0
		enemy_stats["boss"]["bullet_speed"] += 3
		if level < 3:
			enemy_stats["boss"]["firerate"] -= 0.1
	
	if Difficlty == "normal":
		enemy_stats["normal"]["damage"] += 5
		enemy_stats["normal"]["bullets"] += 0
		enemy_stats["normal"]["spread"] += 0
		enemy_stats["normal"]["movement_speed"] += 5
		enemy_stats["normal"]["bullet_speed"] += 10
		if level < 4:
			enemy_stats["normal"]["firerate"] -= 0.1
			
		enemy_stats["shotgun"]["damage"] += 2
		enemy_stats["shotgun"]["bullets"] += 2
		enemy_stats["shotgun"]["spread"] += 8
		enemy_stats["shotgun"]["movement_speed"] += 5
		enemy_stats["shotgun"]["bullet_speed"] += 10
		if level < 4:
			enemy_stats["shotgun"]["firerate"] -= 0.1
		
		enemy_stats["boss"]["damage"] += 10
		enemy_stats["boss"]["bullets"] += 5
		enemy_stats["boss"]["spread"] += 0
		enemy_stats["boss"]["movement_speed"] += 0
		enemy_stats["boss"]["bullet_speed"] += 5
		if level < 4:
			enemy_stats["boss"]["firerate"] -= 0.1

	if Difficlty == "hard":
		enemy_stats["normal"]["damage"] += 10
		enemy_stats["normal"]["bullets"] += 0
		enemy_stats["normal"]["spread"] += 0
		enemy_stats["normal"]["movement_speed"] += 5
		enemy_stats["normal"]["bullet_speed"] += 15
		if level < 5:
			enemy_stats["normal"]["firerate"] -= 0.1
			
		enemy_stats["shotgun"]["damage"] += 4
		enemy_stats["shotgun"]["bullets"] += 4
		enemy_stats["shotgun"]["spread"] += 16
		enemy_stats["shotgun"]["movement_speed"] += 10
		enemy_stats["shotgun"]["bullet_speed"] += 15
		if level < 5:
			enemy_stats["shotgun"]["firerate"] -= 0.1
		
		enemy_stats["boss"]["damage"] += 20
		enemy_stats["boss"]["bullets"] += 10
		enemy_stats["boss"]["spread"] += 0
		enemy_stats["boss"]["movement_speed"] += 0
		enemy_stats["boss"]["bullet_speed"] += 5
		if level < 3:
			enemy_stats["boss"]["firerate"] -= 0.1
	
	if Difficlty == "impossible":
		enemy_stats["normal"]["damage"] += 20
		enemy_stats["normal"]["bullets"] += 0
		enemy_stats["normal"]["spread"] += 0
		enemy_stats["normal"]["movement_speed"] += 20
		enemy_stats["normal"]["bullet_speed"] += 20
		if level < 5:
			enemy_stats["normal"]["firerate"] -= 0.1
			
		enemy_stats["shotgun"]["damage"] += 8
		enemy_stats["shotgun"]["bullets"] += 8
		enemy_stats["shotgun"]["spread"] += 32
		enemy_stats["shotgun"]["movement_speed"] += 20
		enemy_stats["shotgun"]["bullet_speed"] += 20
		if level < 5:
			enemy_stats["shotgun"]["firerate"] -= 0.1
		
		enemy_stats["boss"]["damage"] += 40
		enemy_stats["boss"]["bullets"] += 10
		enemy_stats["boss"]["spread"] += 0
		enemy_stats["boss"]["movement_speed"] += 0
		enemy_stats["boss"]["bullet_speed"] += 5
		if level < 6:
			enemy_stats["boss"]["firerate"] -= 0.1

func difficlty(difficlty):
	Difficlty = difficlty
	if Difficlty == "normal":
		enemy_stats = {
	"normal": {"damage": 10, "health": 150, "bullets": 1, "spread": 0, "movement_speed": 60,"bullet_speed": 100, "firerate": 0.6},
	"boss": {"damage": 10, "health": 1000, "bullets": 20, "spread": 360, "movement_speed": 10, "bullet_speed": 75, "firerate": 1},
	"shotgun": {"damage": 2, "health": 200, "bullets": 5, "spread": 20, "movement_speed": 60, "bullet_speed": 100, "firerate": 1}
}
	elif Difficlty == "easy":
		enemy_stats = {
	"normal": {"damage": 5, "health": 100, "bullets": 1, "spread": 0, "movement_speed": 40,"bullet_speed": 150, "firerate": 0.6},
	"boss": {"damage": 5, "health": 600, "bullets": 20, "spread": 360, "movement_speed": 10, "bullet_speed": 50, "firerate": 1},
	"shotgun": {"damage": 2, "health": 100, "bullets": 5, "spread": 20, "movement_speed": 40, "bullet_speed": 75, "firerate": 1}
}
	elif Difficlty == "hard":
		enemy_stats = {
	"normal": {"damage": 10, "health": 150, "bullets": 1, "spread": 0, "movement_speed": 60,"bullet_speed": 200, "firerate": 0.3},
	"boss": {"damage": 10, "health": 1000, "bullets": 20, "spread": 360, "movement_speed": 10, "bullet_speed": 75, "firerate": 0.5},
	"shotgun": {"damage": 4, "health": 250, "bullets": 5, "spread": 20, "movement_speed": 60, "bullet_speed": 150, "firerate": 0.6}
}
	elif Difficlty == "impossible":
		enemy_stats = {
	"normal": {"damage": 20, "health": 200, "bullets": 1, "spread": 0, "movement_speed": 60,"bullet_speed": 250, "firerate": 0.15},
	"boss": {"damage": 20, "health": 2000, "bullets": 40, "spread": 360, "movement_speed": 10, "bullet_speed": 150, "firerate": 0.25},
	"shotgun": {"damage": 10, "health": 200, "bullets": 10, "spread": 30, "movement_speed": 60, "bullet_speed": 250, "firerate": 0.3}
}
