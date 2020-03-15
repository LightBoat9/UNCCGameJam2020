extends Node

var game_root: Node2D
var floor_tiles: TileMap
var wall_tiles: TileMap
var road_tiles: TileMap
var navigation: Node2D
var generation: Node2D
var player: Node2D
var gui: Control

var block_presets: Array = []

func init_globals():
	var root = get_tree().root
	game_root = root.get_child(root.get_child_count() - 1)
	floor_tiles = game_root.get_node("Floor")
	wall_tiles = game_root.get_node("Walls")
	road_tiles = game_root.get_node("Road")
	navigation = game_root.get_node("Navigation")
	generation = game_root.get_node("Generation")
	player = floor_tiles.get_node("Player")
	gui = player.get_node("CanvasLayer/GUI")
	load_presets()

func load_presets() -> void:
	var file = File.new()
	var dir = Directory.new()
	
	dir.open("res://blocks/presets/")
	dir.change_dir(".")
	dir.list_dir_begin(true)
	
	var path = dir.get_next()
	var err = file.open("res://blocks/presets/%s" % path, File.READ)
	
	while err == OK:
		if path.get_extension() == "json":
			block_presets.append(parse_json(file.get_as_text()))
		
		file.close()
		path = dir.get_next()
		err = file.open("res://blocks/presets/%s" % path, File.READ)
	
	dir.list_dir_end()
