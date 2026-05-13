extends Node

var health: float = 100
var speed: float = 200.0
var ability_speed: float = 2.0
var ability_duration: float = 0.2
var ability_cooldown: float = 0.5

var bullet_damage: float = 100.0
var bullet_speed: float = 400.0
var bullet_range: float = 500.0
var bullet_size: float = 1.0
var bullet_count: int = 1
var bullet_spread: float = 0.0

var auto_fire_active: bool = false
var free_dash: bool = false

func reset():
	health = 100
	speed = 200.0
	ability_speed = 2.0
	ability_duration = 0.2
	ability_cooldown = 0.5

	bullet_damage = 100.0
	bullet_speed = 400.0
	bullet_range = 500.0
	bullet_size = 1.0
	bullet_count = 1
	bullet_spread = 0.0

	auto_fire_active = false
	free_dash = false
