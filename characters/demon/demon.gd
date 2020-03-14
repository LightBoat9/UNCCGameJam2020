extends Character

func _init().():
	character_name = "Demon"

func morph() -> void:
	$AnimationPlayer.play("morph")
	yield($AnimationPlayer, "animation_finished")
	Globals.gui.get_logger().add_log("Demon: SCREEEEEEEEEEEEEEEEEEEEEEEE")
	
func turn_started() -> void:
	.turn_started()
	turn_moves = 1
	var path = Globals.navigation.get_grid_path(grid_position, Globals.player.grid_position)
	
	if path.size() > 1:
		var limit = 50
		while turn_moves > 0 and limit > 0:
			move(path[1])
			limit -= 1
			
		if limit <= 0:
			print("Turn limit reached")
	else:
		Scheduler.go_next()
