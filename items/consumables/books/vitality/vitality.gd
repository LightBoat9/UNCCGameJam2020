extends Consumable

func use_on_character(ch: Node, is_player:=false) -> void:
	ch.max_hp += 5
	ch.hp += 5
	if is_player:
		Globals.gui.get_logger().add_log("You feel your general health has improved.")
	uses -= 1
