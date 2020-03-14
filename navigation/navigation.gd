extends Node2D

var a_star: AStar2D = AStar2D.new()
	
func init_navigation():
	var r = Globals.floor_tiles.get_used_rect()
	
	a_star.reserve_space(r.size.x * r.size.y)
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			var id = get_cell_id(Vector2(x, y))
			a_star.add_point(id, Vector2(x,y))
			
			var disabled = Globals.wall_tiles.get_cell(x, y) != -1 or \
				Globals.game_root.get_objects_at(Vector2(x, y))
			a_star.set_point_disabled(id, disabled)
			
	for y in range(r.position.y, r.position.y + r.size.y):
		for x in range(r.position.x, r.position.x + r.size.x):
			var i = get_cell_id(Vector2(x, y))
			for oy in range(-1, 2):
				for ox in range(-1, 2):
					if ox == 0 and oy == 0:
						continue
					if (x+ox < r.position.x or x+ox >= r.position.x + r.size.x or
						y+oy < r.position.y or y+oy >= r.position.y + r.size.y):
							continue
						
					var p = get_cell_id(Vector2(x+ox, y+oy))
					if a_star.has_point(p):
						a_star.connect_points(i, p)
						
func get_cell_id(pos: Vector2) -> int:
	var r = Globals.floor_tiles.get_used_rect()
	var offset = pos - r.position
	return int(offset.x + offset.y * r.size.x)
	
func set_cell_disabled(pos: Vector2, dis: bool) -> void:
	a_star.set_point_disabled(get_cell_id(pos), dis)
	
func is_cell_disabled(pos: Vector2) -> bool:
	if not a_star.has_point(get_cell_id(pos)):
		return true
		
	return a_star.is_point_disabled(get_cell_id(pos))
	
func set_cell_weight(pos: Vector2, weight: float) -> void:
	a_star.set_point_weight_scale(get_cell_id(pos), weight)
	
func get_grid_path(from: Vector2, to: Vector2, ignore_self:=true, ignore_goal:=true) -> Array:
	if not a_star.has_point(get_cell_id(from)) or not a_star.has_point(get_cell_id(to)):
		return []
	var from_temp = is_cell_disabled(from)
	var to_temp = is_cell_disabled(to)
	if ignore_self:
		set_cell_disabled(from, false)
	if ignore_goal:
		set_cell_disabled(to, false)
	var path = a_star.get_point_path(get_cell_id(from), get_cell_id(to))
	set_cell_disabled(from, from_temp)
	set_cell_disabled(to, to_temp)
	return Array(path)
