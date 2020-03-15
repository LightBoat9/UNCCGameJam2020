class_name Character
extends GridObject

var max_hp: int = 10 setget set_max_hp
var hp: int = max_hp setget set_hp

var character_name: String = "Character"

var can_open: bool = true

var item_limit: int = 3
var items: Array = []

var equipped: Weapon = null setget set_equipped

func _init():
	add_to_group("character")

func _draw() -> void:
	if hp != max_hp and hp > 0:
		draw_rect(Rect2(2, 0, 28, 2), Color(0.5, 0.1, 0.1))
		draw_rect(Rect2(2, 0, 28 * (hp / float(max_hp)), 2), Color.red)

func set_equipped(item: Weapon) -> void:
	equipped = item

func can_add_item(itm: Node) -> bool:
	return items.size() < item_limit

func get_damage() -> Vector2:
	if equipped:
		return equipped.get_damage()
	
	return Vector2(1, 2)

func remove_item(item: Node, drop:=true) -> void:
	if item == equipped:
		self.equipped = null
		
	if drop:
		Globals.game_root.add_object(item, grid_position)
		get_parent().add_child(item)
	
	items.remove(items.find(item))

func add_item(item: Node) -> void:
	Globals.game_root.remove_object(item)
	if item.get_parent():
		item.get_parent().remove_child(item)
		
	items.append(item)

func turn_started() -> void:
	pass

func interact(objs) -> void:
	for obj in objs:
		if obj.is_in_group("character") and obj.hp > 0:
			var dmg = get_damage()
			var roll = int(rand_range(dmg.x, dmg.y+1))
			Globals.gui.get_logger().add_log("%s hits %s for %d damage" % [character_name, obj.character_name, roll])
			obj.hp -= roll
			use_turn_move()
			if equipped and randi() % 100 > equipped.durability:
				if is_in_group("player"):
					Globals.gui.get_logger().add_log("Your %s has broken!" % equipped.object_name)
				equipped.queue_free()
				remove_item(equipped, false)
			return
		elif can_open and obj is Door and obj.state == Door.State.CLOSED:
			obj.state = Door.State.OPEN
			use_turn_move()
			return
		elif obj.is_in_group("items"):
			add_item(obj)
			use_turn_move()
			return
			
	use_turn_move()

func die() -> void:
	Globals.game_root.remove_object(self)
	queue_free()

func move(to: Vector2) -> void:
	var interact = false
	for obj in Globals.game_root.get_objects_at(to):
		if obj.height_level == Height.INTERACT:
			if obj.can_interact():
				interact = true
				break
			
	if not Globals.navigation.is_cell_disabled(to) and not interact:
		var on_climb = Globals.game_root.climb_object_at(grid_position)
		Globals.game_root.move_object(self, to)
		var to_climb = Globals.game_root.climb_object_at(grid_position)
		if (on_climb == null) != (to_climb == null):
			if is_in_group("player"):
				if on_climb:
					Globals.gui.get_logger().add_log("Moving off of this %s is slow." % on_climb.object_name)
				else:
					Globals.gui.get_logger().add_log("Moving onto this %s is slow." % to_climb.object_name)
			Scheduler.go_next()
		else:
			use_turn_move()
			
		var ground_objs = []
		for obj in Globals.game_root.get_objects_at(grid_position):
			if obj.is_in_group("items"):
				ground_objs.append(obj.object_name)
		
		if is_in_group("player"):
			if ground_objs.size() > 1:
				Globals.gui.get_logger().add_log("You see here a %s and %s." % \
					[PoolStringArray(ground_objs.slice(0, -2)).join(", "), ground_objs[-1]])
			elif ground_objs.size() > 0:
				Globals.gui.get_logger().add_log("You see here a %s." % PoolStringArray(ground_objs).join(", "))
	else:
		interact(Globals.game_root.get_objects_at(to))

func set_max_hp(mhp: int) -> void:
	max_hp = mhp
	self.hp = hp
	
func set_hp(h: int) -> void:
	hp = max(0, min(max_hp, h))
	update()
	if hp <= 0:
		die()
	
func get_save_data() -> Dictionary:
	var data = .get_save_data()
	
	data["max_hp"] = max_hp
	data["hp"] = hp
	
	data["items"] = []
	for obj in items:
		data["items"].append(obj.filename)
		
	if equipped:
		data["equipped"] = items.find(equipped)
	else:
		data["equipped"] = -1
	
	return data
	
func load_data(data: Dictionary) -> void:
	.load_data(data)
	self.max_hp = data["max_hp"]
	self.hp = data["hp"]
	
	for obj in data["items"]:
		var inst = load(obj).instance()
		add_item(inst)
	
	if data["equipped"] != -1 and data["equipped"] < items.size():
		self.equipped = items[data["equipped"]]
