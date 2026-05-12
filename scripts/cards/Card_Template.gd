extends TextureButton
class_name Card_Template

@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
@export var hover_animation_length: float = 0.1
@export var un_hover_animation_length: float = 0.1

@export var press_scale: Vector2 = Vector2(0.95, 0.95)
@export var press_animation_length_1: float = 0.1
@export var press_animation_length_2: float = 0.1

var animation_tween: Tween

var data
var player
var shop

@onready var icon = $TextureRect

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_button_hover)
	mouse_exited.connect(_button_un_hover)

	resized.connect(_update_size)
	_update_size()

	if data != null and data.has("image"):
		icon.texture = load(data.image)

func _update_size() -> void:
	if icon.texture == null:
		return

	custom_minimum_size = icon.texture.get_size()

	pivot_offset = size / 2

func _on_button_pressed() -> void:
	_button_press()

	if player == null or data == null:
		return

	apply_upgrade(player)

	if shop:
		shop.on_card_picked(self)

	disabled = true
	modulate = Color(0.0, 0.603, 0.24, 1.0)

	get_tree().paused = false

func apply_upgrade(target_player):

	for e in data.effects:

		match e.type:

			"speed":
				target_player.speed += e.value

			"ability_speed":
				target_player.ability_speed += e.value

			"ability_duration":
				target_player.ability_duration += e.value

			"ability_cooldown":
				target_player.ability_cooldown += e.value

			"bullet_damage":
				target_player.bullet_damage += e.value

			"bullet_speed":
				target_player.bullet_speed += e.value

			"bullet_range":
				target_player.bullet_range += e.value

			"bullet_size":
				target_player.bullet_size += e.value

			"bullet_count":
				target_player.bullet_count += int(e.value)

			"bullet_spread":
				target_player.bullet_spread += e.value

			"auto_fire_toggle":
				target_player.auto_fire_active = !target_player.auto_fire_active

			"free_dash_toggle":
				target_player.free_dash = !target_player.free_dash

func _button_press() -> void:
	if animation_tween:
		animation_tween.kill()

	animation_tween = create_tween().set_trans(Tween.TRANS_SINE)
	animation_tween.tween_property(self, "scale", press_scale, press_animation_length_1)
	animation_tween.chain().tween_property(self, "scale", hover_scale, press_animation_length_2)

func _button_hover() -> void:
	if animation_tween:
		animation_tween.kill()

	animation_tween = create_tween().set_trans(Tween.TRANS_SINE)
	animation_tween.tween_property(self, "scale", hover_scale, hover_animation_length)

func _button_un_hover() -> void:
	if animation_tween:
		animation_tween.kill()

	animation_tween = create_tween().set_trans(Tween.TRANS_SINE)
	animation_tween.tween_property(self, "scale", Vector2.ONE, un_hover_animation_length)
