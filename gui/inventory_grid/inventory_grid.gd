extends GridContainer

const InventorySlot = preload("res://gui/inventory_grid/slot/InventorySlot.tscn")

func from_character(ch: Node) -> void:
	for child in get_children():
		child.queue_free()
		
	for i in range(ch.item_limit):
		var inst = InventorySlot.instance()
		if i < ch.items.size():
			inst.set_texture(ch.items[i].get_profile())
			inst.set_equipped(ch.items[i] == ch.equipped)
		
		inst.set_index(i+1)
		add_child(inst)
	
func from_position(gp: Vector2) -> void:
	for child in get_children():
		child.queue_free()
		
	var i = 1
	var ground = Globals.game_root.get_objects_at(gp)
	for obj in ground:
		if obj.is_in_group("items"):
			var inst = InventorySlot.instance()
			inst.set_texture(obj.get_profile())
			inst.set_index(i)
			add_child(inst)
			i += 1
