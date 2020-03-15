class_name Character
extends GridObject

var max_hp: int = 10 setget set_max_hp
var hp: int = max_hp setget set_hp

var character_name: String = "Character"

var can_open_doors: bool = true

var item_limit: int = 3
var items: Array = []

var equipped: Node = null setget set_equipped

func _init():
	add_to_group("character")

func _draw() -> void:
	if hp != max_hp:
		draw_rect(Rect2(2, 0, 28, 2), Color(0.5, 0.1, 0.1))
		draw_rect(Rect2(2, 0, 28 * (hp / float(max_hp)), 2), Color.red)

func set_equipped(item: Node) -> void:
	assert(item.is_in_group("items"))
	equipped = item

func can_add_item(itm: Node) -> bool:
	return items.size() < item_limit

func remove_item(item: Node) -> void:
	if item == equipped:
		equipped = null
		
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
		if obj.is_in_group("character"):
			Globals.gui.get_logger().add_log("%s hits %s for %d damage" % [character_name, obj.character_name, 1])
			obj.hp -= 1
			use_turn_move()
			return
		elif obj is Door:
			obj.state = Door.State.OPEN
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
					Globals.gui.get_logger().add_log("Moving on to this %s is slow." % to_climb.object_name)
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
	hp = min(max_hp, h)
	update()
	if hp <= 0:
		die()
