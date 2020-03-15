extends Human

signal wait_ended

enum Action {
	MOVE, CLOSE, DROP, GRAB
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

var wait_enter: bool = false

var action: int = Action.MOVE

func _init().():
	add_to_group("player")
	character_name = "Player"
	
func _ready():
	yield(get_tree(), "idle_frame")
	_update_gui()

func _input(event: InputEvent) -> void:
	if not Scheduler.current == self:
		return
		
	if wait_enter:
		if event.is_action_pressed("ui_accept"):
			wait_enter = false
			Globals.gui.get_logger().update_label()
			emit_signal("wait_ended")
			
		return
		
	if action != Action.MOVE and event.is_action_pressed("ui_cancel"):
		Globals.gui.get_logger().add_log("Nevermind.")
		action = Action.MOVE
		
	if action != Action.CLOSE and event.is_action_pressed("close"):
		action = Action.CLOSE
		Globals.gui.get_logger().add_log("Close where?")
	elif action != Action.DROP and event.is_action_pressed("drop"):
		action = Action.DROP
		Globals.gui.get_logger().add_log("Drop what?")
	elif action != Action.GRAB and event.is_action_pressed("grab"):
		action = Action.GRAB
		Globals.gui.get_logger().add_log("Grab what?")
		
	match action:
		Action.MOVE:
			_move_input(event)
		Action.CLOSE:
			_close_input(event)
		Action.DROP:
			_drop_input(event)
		Action.GRAB:
			_grab_input(event)
		
func _move_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo() and event.scancode >= KEY_1 and event.scancode <= KEY_9:
		var ind = event.scancode - KEY_1
		if ind < items.size():
			if self.equipped != items[ind]:
				self.equipped = items[ind]
			else:
				self.equipped = null
			
		_update_gui()
	if event.is_action_pressed("wait", true):
		Scheduler.go_next()
	else:
		for key in InputDirections.keys():
			if event.is_action_pressed(key, true):
				move(grid_position + InputDirections[key])
			
func _close_input(event: InputEvent) -> void:
	for key in InputDirections.keys():
		if event.is_action_pressed(key, true):
			close_at(grid_position + InputDirections[key])
	
func _drop_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo() and event.scancode >= KEY_1 and event.scancode <= KEY_9:
		var ind = event.scancode - KEY_1
		if ind < items.size():
			remove_item(items[ind])
			action = Action.MOVE
			
func _grab_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo() and event.scancode >= KEY_1 and event.scancode <= KEY_9:
		var ind = event.scancode - KEY_1
		var ground = Globals.game_root.get_items_at(grid_position)
		if ind < ground.size():
			if can_add_item(ground[ind]):
				add_item(ground[ind])
				Globals.gui.get_logger().add_log("You pick up the %s." % ground[ind].object_name)
			else:
				Globals.gui.get_logger().add_log("You have no room for the %s." % ground[ind].object_name)
				
			action = Action.MOVE
			
		_update_gui()
	
func close_at(gp: Vector2) -> void:
	for obj in Globals.game_root.get_objects_at(gp):
		if obj is Door:
			match obj.state:
				Door.State.OPEN:
					obj.state = Door.State.CLOSED
					use_turn_move()
					Globals.gui.get_logger().add_log("You closed the door.")
				Door.State.CLOSED:
					Globals.gui.get_logger().add_log("The door is already closed.")
			
			action = Action.MOVE
			return
					
	Globals.gui.get_logger().add_log("Nothing to close there.")
	action = Action.MOVE
	
func move(to: Vector2) -> void:
	if not Globals.game_root.is_inside_grid(to):
		if to.y < 0:
			Globals.game_root.call_deferred("goto_district", Vector2(0, -1))
			self.grid_position = Vector2(grid_position.x, Constants.DISTRICT_GRID_SIZE.y-1)
		elif to.y >= Constants.DISTRICT_GRID_SIZE.y:
			Globals.game_root.call_deferred("goto_district", Vector2(0, 1))
			self.grid_position = Vector2(grid_position.x, 0)
		elif to.x < 0:
			Globals.game_root.call_deferred("goto_district", Vector2(-1, 0))
			self.grid_position = Vector2(Constants.DISTRICT_GRID_SIZE.x-1, grid_position.y)
		elif to.x >= Constants.DISTRICT_GRID_SIZE.x:
			Globals.game_root.call_deferred("goto_district", Vector2(1, 0))
			self.grid_position = Vector2(0, grid_position.y)
	else:
		.move(to)
		Globals.gui.get_ground_inventory().from_position(grid_position)
	
func die() -> void:
	pass
	
func turn_started() -> void:
	.turn_started()
	turn_moves = randi() % 2 + 1
	
func set_hp(hp: int) -> void:
	.set_hp(hp)
	_update_gui()
	
func set_hunger(h: int) -> void:
	.set_hunger(h)
	_update_gui()
	
func set_mutation(m: int) -> void:
	.set_mutation(m)
	_update_gui()
	
func _update_gui():
	Globals.gui.from_character(self)
