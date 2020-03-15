extends Consumable

func use_on_character(ch: Node, is_player:=false) -> void:
	ch.max_stamina += 5
	ch.stamina += 5
	if is_player:
		Globals.gui.get_logger().add_log("You learn techniques to help you run longer")
	uses -= 1
