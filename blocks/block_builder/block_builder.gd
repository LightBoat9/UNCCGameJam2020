tool
extends Node2D
# Super hacky tool to create json files for block presets

export var json_name: String = ""
export var create_json: bool = false setget set_create_json
export var load_json: bool = false setget set_load_json

var data: Dictionary = {}

func create_data():
	data["floor"] = []
	data["walls"] = []
	data["objects"] = {}
	
	var flr = $Floor
	var wls = $Walls
	
	for y in Constants.BLOCK_SIZE.y:
		for x in Constants.BLOCK_SIZE.x:
			data["floor"].append(flr.get_cell(x, y))
			data["walls"].append(wls.get_cell(x, y))
			
	for child in flr.get_children():
		var pos = (child.global_position / Constants.GRID_SIZE).floor()
		
		if not data["objects"].has(pos):
			data["objects"][pos] = []
			
		data["objects"][pos].append(child.filename)

func set_create_json(to: bool) -> void:
	if to:
		create_data()
		
		var file = File.new()
		var path = "res://blocks/presets/%s.json" % json_name
		
		file.open(path, File.WRITE)
		
		file.store_string(to_json(data))
		
		file.close()
	
func set_load_json(to: bool) -> void:
	if to:
		var file = File.new()
		var path = "res://blocks/presets/%s.json" % json_name
		file.open(path, File.READ)
		
		data = parse_json(file.get_as_text())
		
		var flr = $Floor
		var wls = $Walls
	
		for y in Constants.BLOCK_SIZE.y:
			for x in Constants.BLOCK_SIZE.x:
				flr.set_cell(x, y, data["floor"][x + y * Constants.BLOCK_SIZE.x])
				wls.set_cell(x, y, data["walls"][x + y * Constants.BLOCK_SIZE.x])
				
		for obj in flr.get_children():
			obj.queue_free()
				
		for key in data["objects"].keys():
			for obj in data["objects"][key]:
				var vals = key.split(',')
				
				var inst = load(obj).instance()
				inst.global_position = Vector2(int(vals[0]), int(vals[1])) * Constants.GRID_SIZE
				flr.add_child(inst)
				inst.owner = self
				
		$Floor.update_bitmask_region(Vector2(0, 0), Constants.BLOCK_SIZE)
		$Walls.update_bitmask_region(Vector2(0, 0), Constants.BLOCK_SIZE)
