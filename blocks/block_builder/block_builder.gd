tool
extends Node2D
# Super hacky tool to create json files for block presets

export var create_json: bool = false setget set_create_json
export var json_name: String = ""

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
		print(path)
		
		file.open(path, File.WRITE)
		
		file.store_string(to_json(data))
		
		file.close()
