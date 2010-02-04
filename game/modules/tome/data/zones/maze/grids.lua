load("/data/general/grids/basic.lua")

newEntity{
	define_as = "QUICK_EXIT",
	name = "teleporting circle to the surface", image = "terrain/maze_teleport.png",
	display = '>', color_r=255, color_g=0, color_b=255,
	change_level = 1, change_zone = "wilderness",
}

newEntity{
	define_as = "MAZE_FLOOR",
	name = "floor", image = "terrain/maze_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255,
}

newEntity{
	define_as = "MAZE_WALL",
	name = "wall", image = "terrain/granite_wall_lichen.png",
	display = '#', color_r=255, color_g=255, color_b=255,
	block_move = true,
	block_sight = true,
	air_level = -20,
}
