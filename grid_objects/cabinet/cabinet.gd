extends GridObject

const ITEMS: Array = [
	preload("res://items/consumables/canned_food/CannedFood.tscn"),
	preload("res://items/consumables/mask_filter/MaskFilter.tscn"),
	preload("res://items/consumables/bandages/Bandages.tscn"),
]
	
func first_generate() -> void:
	if randf() <= 0.5:
		var item = ITEMS[randi() % ITEMS.size()]
		var inst = item.instance()
		get_parent().add_child(inst)
		inst.grid_position = grid_position
