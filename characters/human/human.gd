class_name Human
extends Character

const Demon: PackedScene = preload("res://characters/demon/Demon.tscn")

var hunger_turns_max: int = 30
var hunger_turns: int = hunger_turns_max setget set_hunger_turns
var hunger: int = 20 setget set_hunger
var max_hunger: int = 20 setget set_max_hunger

var filter_turns_max: int = 20
var filter_turns: int = filter_turns_max setget set_filter_turns
var max_filter: int = 50 setget set_max_filter
var filter: int = max_filter setget set_filter

var stamina_turns_max: int = 5
var stamina_turns: int = stamina_turns_max setget set_stamina_turns
var max_stamina: int = 5 setget set_max_stamina
var stamina: int = max_stamina setget set_stamina

var running: bool = false setget set_running

func morph() -> void:
	Globals.game_root.remove_object(self)
	var inst = Demon.instance()
	Globals.floor_tiles.add_child(inst)
	Globals.game_root.add_object(inst, grid_position)
	inst.morph()
	if not is_in_group("player"):
		queue_free()
	
func set_equipped(eq: Weapon) -> void:
	.set_equipped(eq)
	if eq:
		$Item.texture = eq.item_texture
	else:
		$Item.texture = null
	
func set_max_hunger(mh: int) -> void:
	max_hunger = mh
	self.hunger = hunger
	
func set_hunger(h: int) -> void:
	hunger = max(0, min(max_hunger, h))
	update()
	if hunger <= 0:
		die()
	
func turn_started():
	self.hunger_turns -= 1
	self.filter_turns -= 1
	if not running:
		self.stamina_turns -= 1
	
func set_hunger_turns(to: int) -> void:
	hunger_turns = to
	if hunger_turns <= 0:
		self.hunger -= 1
		hunger_turns = hunger_turns_max
		
func set_filter_turns(to: int) -> void:
	filter_turns = to
	if filter_turns <= 0:
		self.filter -= 1
		filter_turns = filter_turns_max
	
func set_max_filter(mf: int) -> void:
	max_filter = mf
	self.filter = filter
	
func set_filter(f: int) -> void:
	filter = max(0, min(max_filter, f))
	if filter <= 0:
		_morph_started()
		$AnimationPlayer.play("morph")
	update()
	
func set_max_stamina(ms: int) -> void:
	max_stamina = ms
	self.stamina = stamina
	
func set_stamina(s: int) -> void:
	stamina = max(0, min(max_stamina, s))
	if stamina <= 0:
		running = false
	update()

func _morph_started() -> void:
	pass
	
func set_running(to: bool) -> void:
	running = to
	
func set_stamina_turns(st: int) -> void:
	stamina_turns = st
	if stamina_turns <= 0:
		self.stamina += 1
		stamina_turns = stamina_turns_max

func get_save_data() -> Dictionary:
	var data = .get_save_data()
	data["hunger"] = hunger
	data["max_hunger"] = max_hunger
	data["max_filter"] = max_filter
	data["filter"] = filter
	data["max_stamina"] = max_stamina
	data["stamina"] = stamina
	data["running"] = running
	return data
	
func load_data(data: Dictionary) -> void:
	.load_data(data)
	self.max_hunger = data["max_hunger"]
	self.hunger = data["hunger"]
	self.max_filter = data["max_filter"]
	self.filter = data["filter"]
	self.max_stamina = data["max_stamina"]
	self.stamina = data["stamina"]
	self.running = data["running"]
