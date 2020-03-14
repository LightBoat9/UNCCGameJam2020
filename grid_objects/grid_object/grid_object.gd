class_name GridObject
extends Node2D

enum Height {
	GROUND, CLIMB, BLOCK, INTERACT
}

var grid_position: Vector2 setget set_grid_position
var navigation_weight: float = 1.0
var height_level: int = Height.BLOCK

var turn_moves: int = 1

func turn_started() -> void:
	Scheduler.go_next()
	
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
