class_name Door
extends GridObject

enum State {
	CLOSED, OPEN
}

var state: int = State.CLOSED setget set_state

func _init().():
	height_level = Height.INTERACT

func can_interact() -> bool:
	return state == State.CLOSED

func set_state(st: int) -> void:
	state = st
	$Sprite.frame = st
	
	match state:
		State.OPEN:
			navigation_weight = 1.0
		State.CLOSED:
			navigation_weight = 2.0
	
	Globals.game_root.update_cell_navigation(grid_position)
	
