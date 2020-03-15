class_name Consumable
extends Item

export var heal_value: Vector2
export var hunger_value: Vector2
export var filter_value: Vector2
export var uses: int = 1
export var consume_type: String = "eat"

func use_on_character(ch: Node, is_player:=false) -> void:
	var val_hp = int(rand_range(heal_value.x, heal_value.y))
	var val_hun = int(rand_range(hunger_value.x, hunger_value.y))
	var val_fil = int(rand_range(filter_value.x, filter_value.y))
	ch.hp += val_hp
	ch.hunger += val_hun
	ch.filter += val_fil
	uses -= 1
	if is_player:
		var s = "You %s the %s for " % [consume_type, object_name]
	
		var vals = []
		if val_hp != 0:
			vals.append("%d health" % val_hp)
		if val_hun != 0:
			vals.append("%d hunger" % val_hun)
		if val_fil != 0:
			vals.append("%d mutation" % val_fil)
		
		if len(vals) > 1:
			s += PoolStringArray(vals.slice(0, -2)).join(", ")
			s += ", and %s." % vals[-1]
		elif len(vals) > 0:
			s += vals[0] + "."
			
		if len(vals) > 0:
			Globals.gui.get_logger().add_log(s)
	
func get_description() -> String:
	var s = "Restores "
	
	var vals = []
	if heal_value.y > 0:
		vals.append("%d-%d health" % [heal_value.x, heal_value.y])
	if hunger_value.y > 0:
		vals.append("%d-%d hunger" % [hunger_value.x, hunger_value.y])
	if filter_value.y > 0:
		vals.append("%d-%d filter" % [filter_value.x, filter_value.y])
	
	if len(vals) > 1:
		s += PoolStringArray(vals.slice(0, -2)).join(", ")
		s += ", and %s." % vals[-1]
	elif len(vals) > 0:
		s += vals[0] + "."
	
	return s
