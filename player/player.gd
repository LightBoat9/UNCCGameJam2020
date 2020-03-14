extends Human

signal wait_ended

enum Action {
	MOVE, CLOSE
}

const InputDirections: Dictionary = {
	"ui_right": Vector2(1, 0),
	"ui_left": Vector2(-1, 0),
	"ui_up": Vector2(0, -1),
	"ui_down": Vector2(0, 1),
	"ui_down_left": Vector2(-1, 1),
	"ui_down_right": Vector2(1, 1),
	"ui_up_left": Vector2(-1, -1),
	"ui_up_right": Vector2(1, -1),
}

var wait_enter: bool = true

var action: int = Action.MOVE

func _init().():
	character_name = "Player"

func _input(event: InputEvent) -> void:
	if not Scheduler.current == self:
		return
		
	if wait_enter:
		if event.is_action_pressed("ui_accept"):
			wait_enter = false
			Globals.gui.get_logger().update_label()
			emit_signal("wait_ended")
			
		return
		
	if action != Action.CLOSE and event.is_action_pressed("close"):
		action = Action.CLOSE
		Globals.gui.get_logger().add_log("Close where?")
		
	match action:
		Action.MOVE:
			_move_input(event)
		Action.CLOSE:
			_close_input(event)
		
func _move_input(event: InputEvent) -> void:
	if event.is_action_pressed("wait", true):
		Scheduler.go_next()
	else:
		for key in InputDirections.keys():
			if event.is_action_pressed(key, true):
				move(grid_position + InputDirections[key])
			
func _close_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Globals.gui.get_logger().add_log("Nevermind.")
	else:
		for key in InputDirections.keys():
			if event.is_action_pressed(key, true):
				close_at(grid_position + InputDirections[key])
	
func close_at(gp: Vector2) -> void:
	for obj in Globals.game_root.get_objects_at(gp):
		if obj is Door:
			match obj.state:
				Door.State.OPEN:
					obj.state = Door.State.CLOSED
					Globals.gui.get_logger().add_log("You closed the door.")
				Door.State.CLOSED:
					Globals.gui.get_logger().add_log("The door is already closed.")
			
			action = Action.MOVE
			return
					
	Globals.gui.get_logger().add_log("Nothing to close there.")
	action = Action.MOVE
	
func die() -> void:
	pass
	
func turn_started() -> void:
	.turn_started()
	turn_moves = randi() % 2 + 1
