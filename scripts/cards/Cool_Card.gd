extends TextureButton
class_name Cool_Card

@export_category("Hover")
@export var hover_scale: Vector2 = Vector2(1.1, 1.1)
@export var hover_animation_length: float = 0.1
@export var un_hover_animation_length: float = 0.1

@export_category("Press")
@export var press_scale: Vector2 = Vector2(0.95, 0.95)
@export var press_animation_length_1: float = 0.1
@export var press_animation_length_2: float = 0.1

@export_category("Frame Animation")
@export var animated_sprite: AnimatedSprite2D
@export var idle_animation: String = "idle"
@export var hover_animation: String = "hover"
@export var press_animation: String = "press"

@export_category("Scene Navigation")
@export var scene_change: String = ""

var animation_tween: Tween

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP
	
	pressed.connect(_on_button_pressed)
	mouse_entered.connect(_button_hover)
	mouse_exited.connect(_button_un_hover)
	
	resized.connect(_update_pivot)
	_update_pivot()

	if animated_sprite:
		animated_sprite.centered = true
		_update_sprite_position()

		if idle_animation and animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(idle_animation):
			animated_sprite.play(idle_animation)

func _update_pivot() -> void:
	pivot_offset = size / 2
	_update_sprite_position()

func _update_sprite_position() -> void:
	if animated_sprite:
		animated_sprite.position = size / 2

func _on_button_pressed() -> void:
	_button_press()
	var player_stats = _find_player()
	if player_stats != null:
		
		player_stats.free_dash = true
		player_stats.auto_fire_active = true
		
		player_stats.speed *= 2
		#player_stats.ability_speed += 
		#player_stats.ability_duration += 
		#player_stats.ability_cooldown += 
	
		player_stats.bullet_spread += 20
		player_stats.bullet_count += 2
		#player_stats.bullet_cooldown = 
		#player_stats.bullet_speed += 
		#player_stats.bullet_damage += 
		#player_stats.bullet_range += 
		#player_stats.bullet_size += 

		self.disabled = true
		modulate = Color(0.0, 0.603, 0.24, 1.0)
		print("Button smack - Upgrades applied!")
	else:
		print("BRICK")

	if scene_change != "":
		await get_tree().create_timer(0.15).timeout
		get_tree().change_scene_to_file(scene_change)

func _button_press() -> void:
	if animation_tween: 
		animation_tween.kill()
	animation_tween = create_tween().set_trans(Tween.TRANS_SINE)
	animation_tween.tween_property(self, "scale", press_scale, press_animation_length_1)
	animation_tween.chain().tween_property(self, "scale", hover_scale, press_animation_length_2)
	
	if animated_sprite and press_animation:
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(press_animation):
			animated_sprite.play(press_animation)

func _button_hover() -> void:
	if animation_tween:
		animation_tween.kill()
	animation_tween = create_tween().set_trans(Tween.TRANS_SINE)
	animation_tween.tween_property(self, "scale", hover_scale, hover_animation_length)

	if animated_sprite and hover_animation:
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(hover_animation):
			animated_sprite.play(hover_animation)

func _button_un_hover() -> void:
	if animation_tween:
		animation_tween.kill()
	animation_tween = create_tween().set_trans(Tween.TRANS_SINE)
	animation_tween.tween_property(self, "scale", Vector2.ONE, un_hover_animation_length)

	if animated_sprite and idle_animation:
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation(idle_animation):
			animated_sprite.play(idle_animation)

func _find_player() -> Node:
	var players = get_tree().get_nodes_in_group("Cards")
	if players.size() > 0:
		return players[0]
	return null
