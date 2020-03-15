extends Human

signal wait_ended

enum Action {
	MOVE, CLOSE, DROP, GRAB, LOOK
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

var dead: bool = false
var wait_enter: bool = false

var action: int = Action.MOVE

func _init().():
	item_limit = 10
	add_to_group("player")
	character_name = "Player"
	
func _ready():
	call_deferred("_update_gui")
	$Sprite.visible = true
	$Item.visible = true

func _input(event: InputEvent) -> void:
	if not Scheduler.current == self:
		return
		
	if wait_enter:
		if event.is_action_pressed("ui_accept"):
			wait_enter = false
			Globals.gui.get_logger().update_label()
			emit_signal("wait_ended")
			
		return
			
	if dead:
		return
		
	if event.is_action_pressed("save"):
		Globals.game_root.save_game()
		Globals.gui.get_logger().add_log("Saved game.")
		
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
	elif action != Action.LOOK and event.is_action_pressed("look"):
		action = Action.LOOK
		Globals.gui.get_logger().add_log("Look at what item?")
		
	match action:
		Action.MOVE:
			_move_input(event)
		Action.CLOSE:
			_close_input(event)
		Action.DROP:
			_drop_input(event)
		Action.GRAB:
			_grab_input(event)
		Action.LOOK:
			_look_input(event)
		
func _move_input(event: InputEvent) -> void:
	if event.is_action_pressed("run"):
		if stamina == 0:
			Globals.gui.get_logger().add_log("You have no stamina to start running.")
		else:
			self.running = not running
			if running:
				Globals.gui.get_logger().add_log("You begin running.")
			else:
				Globals.gui.get_logger().add_log("You slow to a walk.")
	elif event is InputEventKey and event.pressed and not event.is_echo() and event.scancode >= KEY_0 and event.scancode <= KEY_9:
		var ind = event.scancode - KEY_1
		if event.scancode == KEY_0:
			ind = 9
		if ind < items.size():
			if items[ind] is Weapon:
				if self.equipped != items[ind]:
					self.equipped = items[ind]
				else:
					self.equipped = null
			elif items[ind] is Consumable:
				items[ind].use_on_character(self, true)
				if items[ind].uses <= 0:
					items[ind].queue_free()
					remove_item(items[ind], false)
			
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
	if event is InputEventKey and event.pressed and not event.is_echo() and event.scancode >= KEY_0 and event.scancode <= KEY_9:
		var ind = event.scancode - KEY_1
		if event.scancode == KEY_0:
			ind = 9
		if Globals.game_root.get_items_at(grid_position).size() >= 5:
			Globals.gui.get_logger().add_log("Cannot drop anymore items here.")
		elif ind < items.size():
			Globals.gui.get_logger().add_log("You drop the %s." % items[ind].object_name)
			remove_item(items[ind])
			action = Action.MOVE
			_update_gui()
			
func _look_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo() and event.scancode >= KEY_0 and event.scancode <= KEY_9:
		var ind = event.scancode - KEY_1
		if event.scancode == KEY_0:
			ind = 9
		if ind < items.size():
			Globals.gui.get_logger().add_log(items[ind].get_description())
			action = Action.MOVE
			
func _grab_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo() and event.scancode >= KEY_0 and event.scancode <= KEY_9:
		var ind = event.scancode - KEY_1
		if event.scancode == KEY_0:
			ind = 9
		var ground = Globals.game_root.get_items_at(grid_position)
		if ind < ground.size():
			if can_add_item(ground[ind]):
				add_item(ground[ind])
				use_turn_move()
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
			Globals.game_root.call_deferred("goto_district", Globals.game_root.current_district + Vector2(0, -1))
			self.grid_position = Vector2(grid_position.x, Constants.DISTRICT_GRID_SIZE.y-1)
		elif to.y >= Constants.DISTRICT_GRID_SIZE.y:
			Globals.game_root.call_deferred("goto_district", Globals.game_root.current_district + Vector2(0, 1))
			self.grid_position = Vector2(grid_position.x, 0)
		elif to.x < 0:
			Globals.game_root.call_deferred("goto_district", Globals.game_root.current_district + Vector2(-1, 0))
			self.grid_position = Vector2(Constants.DISTRICT_GRID_SIZE.x-1, grid_position.y)
		elif to.x >= Constants.DISTRICT_GRID_SIZE.x:
			Globals.game_root.call_deferred("goto_district", Globals.game_root.current_district + Vector2(1, 0))
			self.grid_position = Vector2(0, grid_position.y)
	else:
		.move(to)
		Globals.gui.get_ground_inventory().from_position(grid_position)
	
	if running:
		self.stamina -= 1
	
func morph() -> void:
	Globals.gui.get_logger().add_log("Your mask filters run dry, you have mutated into a demon.")
	.morph()
	
func die() -> void:
	$Sprite.visible = false
	$Item.visible = false
	Globals.gui.get_logger().add_log("You are dead...", true)
	yield(self, "wait_ended")
	Globals.game_root.call_deferred("restart")
	
func turn_started() -> void:
	.turn_started()
	if running:
		turn_moves = 2
	else:
		turn_moves = 1 if randf() > 0.1 else 2
	
func turn_ended() -> void:
	Globals.game_root.player_turn_ended()
	
func set_hp(hp: int) -> void:
	.set_hp(hp)
	_update_gui()
	
func set_hunger(h: int) -> void:
	.set_hunger(h)
	_update_gui()
	
func set_filter(m: int) -> void:
	.set_filter(m)
	_update_gui()
	
func set_stamina(s: int) -> void:
	.set_stamina(s)
	if running and stamina <= 0:
		Globals.gui.get_logger().add_log("You run out of breath and slow to a walk")
	_update_gui()
	
func remove_item(item: Node, drop:=true) -> void:
	.remove_item(item, drop)
	_update_gui()
	
func add_item(item: Node) -> void:
	.add_item(item)
	Globals.gui.get_logger().add_log("You pick up the %s." % item.object_name)
	_update_gui()
	
func set_running(to: bool) -> void:
	.set_running(to)
	_update_gui()
	
func _morph_started() -> void:
	dead = true
	
func _update_gui():
	Globals.gui.from_character(self)
	
func get_save_data() -> Dictionary:
	var data = .get_save_data()
	data["wait_enter"] = wait_enter
	data["action"] = action
	
	return data
	
func load_data(data: Dictionary) -> void:
	.load_data(data)
	self.wait_enter = data["wait_enter"]
	self.action = data["action"]
	
func get_description() -> String:
	return "..."
