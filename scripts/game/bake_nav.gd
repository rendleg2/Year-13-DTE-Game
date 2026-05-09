extends NavigationRegion2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_test_map_generation_verson_2_bake_nav() -> void:
	bake_navigation_polygon(true)
