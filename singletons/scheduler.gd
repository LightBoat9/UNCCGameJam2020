extends Node

var current: Node = null setget set_current_object
var queue: Array = []

func reset() -> void:
	current = null
	queue.clear()

func set_current_object(obj: Node) -> void:
	if current != null:
		current.turn_ended()
		
	current = obj
	
	if current:
		current.turn_started()

func go_next() -> void:
	var next = queue.pop_front()
	queue.append(next)
	self.current = next
