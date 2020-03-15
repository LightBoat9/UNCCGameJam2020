class_name GridObject
extends Node2D

enum Height {
	GROUND, CLIMB, BLOCK, INTERACT
}

var grid_position: Vector2 setget set_grid_position
var navigation_weight: float = 1.0
export(Height) var height_level: int = Height.BLOCK

var turn_moves: int = 1
export var object_name: String = "Object"

func first_generate() -> void:
	pass

func turn_started() -> void:
	Scheduler.call_deferred("go_next")
	
func turn_ended() -> void:
	pass

func can_interact() -> bool:
	return false

func set_grid_position(gp: Vector2) -> void:
	grid_position = gp
	global_position = grid_position * Constants.GRID_SIZE
	
func use_turn_move() -> void:
	turn_moves -= 1
	if turn_moves <= 0:
		Scheduler.go_next()
	
func get_save_data() -> Dictionary:
	var data = {}
	data["grid_position"] = grid_position
	data["navigation_weight"] = navigation_weight
	data["turn_moves"] = turn_moves
	return data
	
func load_data(data: Dictionary) -> void:
	var vals = data["grid_position"].split(",")
	self.grid_position = Vector2(int(vals[0]), int(vals[1]))
	self.navigation_weight = data["navigation_weight"]
	self.turn_moves = data["turn_moves"]
	
func get_description() -> String:
	return "..."
