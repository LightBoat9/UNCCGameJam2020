extends Control

func _init():
	visible = true

func get_logger() -> Control:
	return $HBoxContainer/VBox/Log as Control
