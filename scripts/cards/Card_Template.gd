extends TextureButton
class_name Card_Template

var hover_scale: Vector2 = Vector2(1.15, 1.15)

@export var size_multiplier: float = 2.0

var animation_tween: Tween

var data
var shop

var real_texture: Texture2D
var revealed: bool = false

@onready var icon = $TextureRect

var mystery_texture = load("res://assets/sprites/mystery.png")

func _ready():

	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)

	call_deferred("setup_card")

func setup_card():

	if data != null and data.has("image"):
		real_texture = load(data.image)

	icon.texture = mystery_texture

	await get_tree().process_frame

	var base_size = Vector2(180, 240)

	if real_texture != null:
		base_size = real_texture.get_size()

	custom_minimum_size = base_size * size_multiplier
	size = custom_minimum_size

	icon.set_anchors_preset(Control.PRESET_FULL_RECT)

func reveal():

	if revealed:
		return

	revealed = true

	if real_texture != null:
		icon.texture = real_texture

func _on_hover():

	reveal()

	if animation_tween:
		animation_tween.kill()

	animation_tween = create_tween()
	animation_tween.tween_property(self, "scale", hover_scale * size_multiplier, 0.1)

func _on_unhover():

	if animation_tween:
		animation_tween.kill()

	animation_tween = create_tween()
	animation_tween.tween_property(self, "scale", Vector2.ONE * size_multiplier, 0.1)

func _on_pressed():

	_apply_upgrade()

	if shop:
		shop.on_card_picked(self)

	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/game_loop/map_generator.tscn")

func _apply_upgrade():

	for e in data.effects:

		match e.type:

			"speed":
				Global.speed += e.value

			"ability_speed":
				Global.ability_speed += e.value

			"ability_duration":
				Global.ability_duration += e.value

			"ability_cooldown":
				Global.ability_cooldown += e.value

			"bullet_damage":
				Global.bullet_damage += e.value

			"bullet_speed":
				Global.bullet_speed += e.value

			"bullet_range":
				Global.bullet_range += e.value

			"bullet_size":
				Global.bullet_size += e.value

			"bullet_count":
				Global.bullet_count += int(e.value)

			"bullet_spread":
				Global.bullet_spread += e.value

			"auto_fire_toggle":
				Global.auto_fire_active = true

			"free_dash_toggle":
				Global.free_dash = true
				
			"fire_rate":
				Global.fire_rate -= e.value
