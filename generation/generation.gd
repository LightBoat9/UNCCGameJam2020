extends Node2D

func init_generation():
	for dy in range(Constants.DISTRICT_SIZE.y):
		for dx in range(Constants.DISTRICT_SIZE.x):
			var block = random_block_preset()
			for by in range(Constants.BLOCK_SIZE.y):
				for bx in range(Constants.BLOCK_SIZE.x):
					var pos = Vector2(dx, dy) * Constants.BLOCK_SIZE + Constants.ROAD_SIZE + Vector2(bx, by)
					
					Globals.floor_tiles.set_cellv(pos, \
						block["floor"][bx + by * Constants.BLOCK_SIZE.x])
						
					Globals.wall_tiles.set_cellv(pos, \
						block["walls"][bx + by * Constants.BLOCK_SIZE.x])
						
					if block["objects"].has("(%d, %d)" % [bx, by]):
						var ids = block["objects"]["(%d, %d)" % [bx, by]]
						for id in ids:
							var inst = load(id).instance()
							inst.grid_position = pos
							Globals.floor_tiles.add_child(inst)
							inst.first_generate()
								
	var r = Globals.floor_tiles.get_used_rect()
	
	Globals.wall_tiles.update_bitmask_region(r.position, r.position + r.size)
	
func random_block_preset() -> Array:
	return Globals.block_presets[randi() % Globals.block_presets.size()]
