extends Node2D

func init_generation():
	for dy in range(Constants.DISTRICT_SIZE.y):
		for dx in range(Constants.DISTRICT_SIZE.x):
			for by in range(Constants.ROAD_WIDTH, Constants.BLOCK_SIZE.y):
				for bx in range(Constants.ROAD_WIDTH, Constants.BLOCK_SIZE.x):
					if by == Constants.ROAD_WIDTH or by == Constants.BLOCK_SIZE.y-1 or \
						bx == Constants.ROAD_WIDTH or bx == Constants.BLOCK_SIZE.x-1:
							Globals.wall_tiles.set_cellv(Vector2(dx, dy) * \
								Constants.BLOCK_SIZE + Vector2(bx, by), 0)
								
	var r = Globals.floor_tiles.get_used_rect()
	
	Globals.wall_tiles.update_bitmask_region(r.position, r.position + r.size)
