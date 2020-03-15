extends GridObject

const ITEMS: Array = [
	preload("res://items/weapons/bat/Bat.tscn"),
	preload("res://items/weapons/shovel/Shovel.tscn"),
	preload("res://items/consumables/canned_food/CannedFood.tscn"),
	preload("res://items/consumables/bandages/Bandages.tscn"),
]

func _init():
	object_name = "table"
	height_level = Height.CLIMB
	
func first_generate() -> void:
	if randf() <= 0.5:
		var item = ITEMS[randi() % ITEMS.size()]
		var inst = item.instance()
		get_parent().add_child(inst)
		inst.grid_position = grid_position
