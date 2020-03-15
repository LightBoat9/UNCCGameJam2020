class_name Item
extends GridObject

export var item_texture: Texture

func _init():
	add_to_group("items")
	height_level = Height.GROUND
	
func get_profile() -> Texture:
	return null
