class_name Human
extends Character

const Demon: PackedScene = preload("res://characters/demon/Demon.tscn")

var hunger_turns_max: int = 30
var hunger_turns: int = hunger_turns_max
var hunger: int = 20 setget set_hunger
var max_hunger: int = 20 setget set_max_hunger

var mutation_turns_max: int = 30
var mutation_turns: int = mutation_turns_max
var mutation: int = 0 setget set_mutation
var max_mutation: int = 10 setget set_max_mutation

func morph() -> void:
	Globals.game_root.remove_object(self)
	var inst = Demon.instance()
	Globals.floor_tiles.add_child(inst)
	Globals.game_root.add_object(inst, grid_position)
	inst.morph()
	queue_free()
	
func set_equipped(eq: Node) -> void:
	.set_equipped(eq)
	$Item.texture = eq.item_texture
	
func set_max_hunger(mh: int) -> void:
	max_hunger = mh
	self.hunger = hunger
	
func set_hunger(h: int) -> void:
	hunger = min(max_hunger, h)
	update()
	if hunger <= 0:
		die()
	
func turn_started():
	hunger_turns -= 1
	if hunger_turns <= 0:
		hunger -= 1
		hunger_turns = hunger_turns_max
	
func set_max_mutation(mm: int) -> void:
	max_mutation = mm
	self.mutation = mutation
	
func set_mutation(m: int) -> void:
	mutation = min(max_mutation, m)
	update()
