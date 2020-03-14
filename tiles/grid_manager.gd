extends Node2D

var objects: Dictionary = {}

func _ready():
	Globals.init_globals()
	Globals.generation.init_generation()
	Globals.navigation.init_navigation()
	init_objects()
	Scheduler.go_next()

func init_objects():
	for child in $Floor.get_children():
		add_object(child, (child.global_position / Constants.GRID_SIZE).floor())

func add_object(obj: GridObject, gp: Vector2) -> void:
	var limit = Globals.floor_tiles.get_used_rect()
	
	obj.grid_position = Vector2(clamp(gp.x, limit.position.x, limit.size.x-1), \
		clamp(gp.y, limit.position.y, limit.size.y-1))
	
	if not objects.has(obj.grid_position):
		objects[obj.grid_position] = []
		
	if not obj in Scheduler.queue:
		Scheduler.queue.append(obj)
		
	objects[obj.grid_position].append(obj)
	
	update_cell_navigation(obj.grid_position)
	
func remove_object(obj: GridObject) -> void:
	assert(objects.has(obj.grid_position))
	
	objects[obj.grid_position].remove(objects[obj.grid_position].find(obj))
		
	if obj in Scheduler.queue:
		Scheduler.queue.remove(Scheduler.queue.find(obj))
	
	if objects[obj.grid_position].empty():
		objects.erase(obj.grid_position)
		
	update_cell_navigation(obj.grid_position)
	
func move_object(obj: GridObject, to: Vector2) -> void:
	assert(obj in objects[obj.grid_position])
	
	remove_object(obj)
	add_object(obj, to)
	update_cell_navigation(to)
	
func get_objects_at(gp: Vector2) -> Array:
	if objects.has(gp):
		return objects[gp]
	else:
		return []

func update_cell_navigation(gp: Vector2) -> void:
	Globals.navigation.set_cell_disabled(gp, false)
	var max_weight = 1.0
	for obj in get_objects_at(gp):
		if obj.height_level == GridObject.Height.BLOCK:
			Globals.navigation.set_cell_disabled(gp, true)
			max_weight = max(max_weight, obj.navigation_weight)
			
	Globals.navigation.set_cell_weight(gp, max_weight)
