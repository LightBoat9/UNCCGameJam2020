extends GridObject

const ITEMS: Array = [
	preload("res://items/consumables/bandages/Bandages.tscn"),
	preload("res://items/consumables/books/fitness/Fitness.tscn"),
	preload("res://items/consumables/books/vitality/Vitality.tscn")
]
	
func first_generate() -> void:
	if randf() <= 0.1:
		var item = ITEMS[randi() % ITEMS.size()]
		var inst = item.instance()
		get_parent().add_child(inst)
		inst.grid_position = grid_position
		
