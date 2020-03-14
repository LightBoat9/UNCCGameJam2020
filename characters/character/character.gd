class_name Character
extends GridObject

var max_hp: int = 10 setget set_max_hp
var hp: int = max_hp setget set_hp

var character_name: String = "Character"

var can_open_doors: bool = true

func _init():
	add_to_group("character")
	
func turn_started() -> void:
	pass

func _draw() -> void:
	draw_rect(Rect2(2, 0, 28, 2), Color(0.5, 0.1, 0.1))
	draw_rect(Rect2(2, 0, 28 * (hp / float(max_hp)), 2), Color.red)

func interact(objs) -> void:
	for obj in objs:
		if obj.is_in_group("character"):
			Globals.gui.get_logger().add_log("%s hits %s for %d damage" % [character_name, obj.character_name, 1])
			obj.hp -= 1
			use_turn_move()
			return
		elif obj is Door:
			obj.state = Door.State.OPEN

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
		Globals.game_root.move_object(self, to)
		use_turn_move()
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
