extends Character

var goal_position: Vector2 = Vector2(-1, -1)

func _init().():
	character_name = "Demon"

func morph() -> void:
	$AnimationPlayer.play("morph")
	yield($AnimationPlayer, "animation_finished")
	Globals.gui.get_logger().add_log("Demon: SCREEEEEEEEEEEEEEEEEEEEEEEE")
	
func turn_started() -> void:
	.turn_started()
	turn_moves = 1# if randf() > 0.1 else 2
	if Globals.game_root.has_line_of_sight(grid_position, Globals.player.grid_position):
		goal_position = Globals.player.grid_position
	elif goal_position == Vector2(-1, -1) or grid_position == goal_position:
		goal_position = Globals.game_root.random_open_position()
	
	var path = Globals.navigation.get_grid_path(grid_position, goal_position)

	if path.size() > 1:
		var limit = 50
		while turn_moves > 0 and limit > 0:
			move(path[1])
			limit -= 1
	else:
		Scheduler.go_next()
