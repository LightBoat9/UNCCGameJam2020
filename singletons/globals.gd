extends Node

var game_root: Node2D
var floor_tiles: TileMap
var wall_tiles: TileMap
var navigation: Node2D
var generation: Node2D
var player: Node2D
var gui: Control

func init_globals():
	var root = get_tree().root
	game_root = root.get_child(root.get_child_count() - 1)
	floor_tiles = game_root.get_node("Floor")
	wall_tiles = game_root.get_node("Walls")
	navigation = game_root.get_node("Navigation")
	generation = game_root.get_node("Generation")
	player = floor_tiles.get_node("Player")
	gui = player.get_node("CanvasLayer/GUI")
