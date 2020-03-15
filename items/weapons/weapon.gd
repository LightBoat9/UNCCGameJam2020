class_name Weapon
extends Item

export var damage: Vector2 = Vector2(2, 3)
	
func get_damage():
	return damage

func get_description() -> String:
	return "This %s does %d-%d damage. It has a durability of %d." % [object_name, damage.x, damage.y, durability]
