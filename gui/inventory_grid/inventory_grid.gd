extends GridContainer

const InventorySlot = preload("res://gui/inventory_grid/slot/InventorySlot.tscn")

func from_character(ch: Node) -> void:
	for child in get_children():
		child.set_texture(null)
		
	for i in range(ch.item_limit):
		var inst = get_child(i)
		if i < min(10, ch.items.size()):
			inst.set_texture(ch.items[i].get_profile())
			inst.set_equipped(ch.items[i] == ch.equipped)
		
		inst.set_index(i+1 if i <= 8 else 0)
	
func from_position(gp: Vector2) -> void:
	for child in get_children():
		child.set_texture(null)
	var i = 1
	var ground = Globals.game_root.get_objects_at(gp)
	var objs = ground.slice(0, min(5, ground.size()-1))
	for obj in objs:
		if obj.is_in_group("items"):
			var inst = get_child(i-1)
			inst.set_texture(obj.get_profile())
			if i <= 10:
				inst.set_index(i if i <= 9 else 0)
			i += 1
