class_name Human
extends Character

const Demon: PackedScene = preload("res://characters/demon/Demon.tscn")

func morph() -> void:
	Globals.game_root.remove_object(self)
	var inst = Demon.instance()
	Globals.floor_tiles.add_child(inst)
	Globals.game_root.add_object(inst, grid_position)
	inst.morph()
	queue_free()
