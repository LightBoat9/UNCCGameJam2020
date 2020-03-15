extends Node2D

const Player = preload("res://player/Player.tscn")

var objects: Dictionary = {}
var current_district: Vector2 = Vector2(0, 0)

func _ready():
	print(OS.get_user_data_dir())
	randomize()
	new_game()
	new_district()
	
func new_game():
	var dir = Directory.new()
	if not dir.dir_exists("user://save"):
		dir.make_dir("user://save")
	else:
		dir.change_dir("user://save")
		dir.list_dir_begin(true)
		var path = dir.get_next()
		print(path)
		
		while dir.file_exists("user://save/%s" % path):
			print(path)
			dir.remove("user://save/%s" % path)
			path = dir.get_next()
		
		dir.list_dir_end()
		
func get_district_filepath(district: Vector2) -> String:
	return "user://save/district[%s+%s].json" % [district.x, district.y]
		
func goto_district(district: Vector2):
	assert(current_district != district)
	
	var dir = Directory.new()
	var path = get_district_filepath(district)
	save_current_district()
	if dir.file_exists(path):
		load_district(district)
	else:
		new_district()
		
	current_district = district
		
func load_district(district: Vector2) -> void:
	for child in $Floor.get_children():
		remove_object(child)
		if not child.is_in_group("player"):
			child.free()
	
	objects.clear()
	
	Globals.init_globals()
	Globals.floor_tiles.clear()
	Globals.wall_tiles.clear()
	
	var file = File.new()
	file.open(get_district_filepath(district), File.READ)
	
	var data = parse_json(file.get_as_text())
	
	file.close()
	
	for y in Constants.DISTRICT_GRID_SIZE.y:
		for x in Constants.DISTRICT_GRID_SIZE.x:
			$Floor.set_cell(x, y, data["floor"][x + y * Constants.DISTRICT_GRID_SIZE.x])
			$Walls.set_cell(x, y, data["walls"][x + y * Constants.DISTRICT_GRID_SIZE.x])
			
			if data["objects"].has("(%d, %d)" % [x, y]):
				var ids = data["objects"]["(%d, %d)" % [x, y]]
				for id in ids:
					var inst = load(id).instance()
					inst.grid_position = Vector2(x, y)
					Globals.floor_tiles.add_child(inst)
					
	var r = Globals.road_tiles.get_used_rect()
	Globals.wall_tiles.update_bitmask_region(r.position, r.position + r.size)
	Globals.floor_tiles.update_bitmask_region(r.position, r.position + r.size)
					
	Globals.navigation.init_navigation()
	
	init_objects()
	Scheduler.go_next()
	
func save_current_district():
	var data = {}
	data["floor"] = []
	data["walls"] = []
	data["objects"] = {}
	
	var flr = $Floor
	var wls = $Walls
	
	for y in Constants.DISTRICT_GRID_SIZE.y:
		for x in Constants.DISTRICT_GRID_SIZE.x:
			data["floor"].append(flr.get_cell(x, y))
			data["walls"].append(wls.get_cell(x, y))
			
	for child in flr.get_children():
		if not child.is_in_group("player"):
			var pos = child.grid_position
			
			if not data["objects"].has(pos):
				data["objects"][pos] = []
				
			data["objects"][pos].append(child.filename)
		
	var path = get_district_filepath(current_district)
	var file = File.new()
	
	file.open(path, File.WRITE)
	
	file.store_string(to_json(data))
	
	file.close()
	
func new_district():
	for child in $Floor.get_children():
		remove_object(child)
		if not child.is_in_group("player"):
			child.free()
	
	objects.clear()
	
	Globals.init_globals()
	Globals.floor_tiles.clear()
	Globals.wall_tiles.clear()
	Globals.generation.init_generation()
	Globals.navigation.init_navigation()
	
	init_objects()
	Scheduler.go_next()

func init_objects():
	for child in $Floor.get_children():
		add_object(child, (child.global_position / Constants.GRID_SIZE).floor())

func is_inside_grid(gp: Vector2) -> bool:
	var grid = Globals.road_tiles.get_used_rect()
	return grid.has_point(gp)

func add_object(obj: GridObject, gp: Vector2) -> void:
	var limit = Globals.road_tiles.get_used_rect()
	
	obj.grid_position = Vector2(clamp(gp.x, limit.position.x, limit.size.x-1), \
		clamp(gp.y, limit.position.y, limit.size.y-1))
	
	if not objects.has(obj.grid_position):
		objects[obj.grid_position] = []
		
	if not obj in Scheduler.queue:
		Scheduler.queue.append(obj)
		
	objects[obj.grid_position].append(obj)
	
	update_cell_navigation(obj.grid_position)
	
func remove_object(obj: GridObject) -> void:
	if not objects.has(obj.grid_position):
		return
	
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
		
func get_items_at(gp: Vector2) -> Array:
	var itms = []
	for obj in get_objects_at(gp):
		if obj.is_in_group("items"):
			itms.append(obj)
			
	return itms

func climb_object_at(gp: Vector2) -> GridObject:
	for obj in get_objects_at(gp):
		if obj.height_level == GridObject.Height.CLIMB:
			return obj
			
	return null

func update_cell_navigation(gp: Vector2) -> void:
	Globals.navigation.set_cell_disabled(gp, false)
	var max_weight = 1.0
	for obj in get_objects_at(gp):
		if obj.height_level == GridObject.Height.BLOCK:
			Globals.navigation.set_cell_disabled(gp, true)
			max_weight = max(max_weight, obj.navigation_weight)
			
	Globals.navigation.set_cell_weight(gp, max_weight)
