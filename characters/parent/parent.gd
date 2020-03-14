extends Human

func _ready() -> void:
	yield(get_tree(), "idle_frame")
	Globals.gui.get_logger().add_log("Mom: Sweetie...put on this mask. Whatever you do don't take it off.", true)
	yield(Globals.player, "wait_ended")
	Globals.gui.get_logger().add_log("Mom: Now *cough* you have to leave, find others who can help.", true)
	yield(Globals.player, "wait_ended")
	Globals.gui.get_logger().add_log("Mom: Quickly! I *cough* *cough* don't have much longer.", true)
	
func turn_started():
	$AnimationPlayer.play("morph")
	yield($AnimationPlayer, "animation_finished")
	Scheduler.go_next()
