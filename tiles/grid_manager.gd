extends Node2D

const Player = preload("res://player/Player.tscn")

var objects: Dictionary = {}
var current_district: Vector2 = Vector2(0, 0)

var next_spawn = 20

var difficulty: int = 0
var max_difficulty: int = 10

func _ready():
	print(OS.get_user_data_dir())
	var dir = Directory.new()
	if not dir.dir_exists("user://save") or not dir.file_exists("user://save/player.json"):
		restart()
	else:
		var player = Player.instance()
		$Floor.add_child(player)
		
		load_district(current_district)
	
func restart():
	randomize()
	if Globals.player:
		Globals.player.free()
	
	var player = Player.instance()
	player.global_position = Vector2(12, 12) * Constants.GRID_SIZE
	$Floor.add_child(player)
	
	new_game()
	new_district()
	save_game()
	
func new_game():
	var dir = Directory.new()
	if not dir.dir_exists("user://save"):
		dir.make_dir("user://save")
	else:
		dir.open("user://save")
		dir.list_dir_begin(true)
		var path = dir.get_next()
		
		while dir.file_exists("user://save/%s" % path):
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
					var inst = load(id["filepath"]).instance()
					inst.grid_position = Vector2(x, y)
					Globals.floor_tiles.add_child(inst)
					inst.load_data(id)
					
	var r = Globals.road_tiles.get_used_rect()
	Globals.wall_tiles.update_bitmask_region(r.position, r.position + r.size)
	Globals.floor_tiles.update_bitmask_region(r.position, r.position + r.size)
					
	Globals.navigation.init_navigation()
	
	Scheduler.reset()
	load_player_data(Globals.player)
	init_objects()
	Scheduler.go_next()
	
func save_player_data(player: Node):
	var pd = player.get_save_data()
	
	var file = File.new()
	file.open("user://save/player.json", File.WRITE)
	file.store_string(to_json(pd))
	file.close()
	
func load_player_data(player: Node):
	var file = File.new()
	file.open("user://save/player.json", File.READ)
	var pd = parse_json(file.get_as_text())
	file.close()
	player.load_data(pd)
	
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
				
			var inst_data = child.get_save_data()
			inst_data["filepath"] = child.filename
			data["objects"][pos].append(inst_data)
		
	var path = get_district_filepath(current_district)
	var file = File.new()
	
	file.open(path, File.WRITE)
	
	file.store_string(to_json(data))
	
	file.close()
	
func save_game():
	save_player_data(Globals.player)
	save_current_district()
	
func new_district():
	difficulty += 1
	
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
	
	Scheduler.reset()
	init_objects()
	Scheduler.go_next()
	save_player_data(Globals.player)

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
	
	if not objects[obj.grid_position].has(obj):
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
	
func player_turn_ended() -> void:
	next_spawn -= 1
	
	if next_spawn <= 0:
		var demon = preload("res://characters/demon/Demon.tscn")
		var inst = demon.instance()
		$Floor.add_child(inst)

		var pos = Vector2(0, 0)
		var r = Globals.road_tiles.get_used_rect()
		if randf() < 0.5:
			if randf() < 0.5:
				pos = Vector2(0, int(rand_range(0, r.size.y)))
			else:
				pos = Vector2(r.size.x - 1, int(rand_range(0, r.size.y)))
		else:
			if randf() < 0.5:
				pos = Vector2(int(rand_range(0, r.size.x)), 0)
			else:
				pos = Vector2(int(rand_range(0, r.size.x)), r.size.y - 1)
		
		add_object(inst, pos)
		next_spawn = randi() % int(200 - 150 * difficulty) + 1

func random_open_position() -> Vector2:
	var r = Globals.road_tiles.get_used_rect()
	var pos = Vector2(int(rand_range(0, r.size.x)), int(rand_range(0, r.size.y)))
	while Globals.navigation.is_cell_disabled(pos):
		pos = Vector2(int(rand_range(0, r.size.x)), int(rand_range(0, r.size.y)))
		
	return pos
	
func get_grid_line(gp1: Vector2, gp2: Vector2) -> Array:
	if abs(gp2.y - gp1.y) < abs(gp2.x - gp1.x):
		if (gp1.x > gp2.x):
			return _line_low(gp2, gp1)
		else:
			return _line_low(gp1, gp2)
	else:
		if (gp1.y > gp2.y):
			return _line_high(gp2, gp1)
		else:
			return _line_high(gp1, gp2)
	
func has_line_of_sight(gp1: Vector2, gp2: Vector2) -> bool:
	for point in get_grid_line(gp1, gp2).slice(1, -2):
		if Globals.navigation.is_cell_disabled(point):
			return false
			
	return true

func _line_low(gp1: Vector2, gp2: Vector2) -> Array:
	var dx = gp2.x - gp1.x
	var dy = gp2.y - gp1.y
	var yi = 1
	if dy < 0:
		yi = -1
		dy = -dy
	
	var D = 2 * dy - dx
	var y = gp1.y
	
	var line = []
	for x in range(gp1.x, gp2.x + 1):
		line.append(Vector2(x, y))
		if D > 0:
			y = y + yi
			D = D - 2 * dx
		
		D = D + 2 * dy
		
	return line
		
func _line_high(gp1: Vector2, gp2: Vector2) -> Array:
	var dx = gp2.x - gp1.x
	var dy = gp2.y - gp1.y
	
	var xi = 1
	if dx < 0:
		xi = -1
		dx = -dx
		
	var D = 2 * dx - dy
	var x = gp1.x
	
	var line = []
	for y in range(gp1.y, gp2.y + 1):
		line.append(Vector2(x, y))
		if D > 0:
			x = x + xi
			D = D - 2 * dy
		
		D = D + 2 * dx
	
	return line
