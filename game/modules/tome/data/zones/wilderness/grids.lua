newEntity{
	define_as = "DUN_ANCIENT_RUINS",
	name = "entrance to ancient ruins",
	display = '>', color_r=255, color_g=0, color_b=255,
	change_level = 1,
	change_zone = "ancient_ruins",
}

newEntity{
	define_as = "FLOOR",
	name = "floor",
	display = '.', color_r=255, color_g=255, color_b=255,
}

newEntity{
	define_as = "WALL",
	name = "wall",
	display = '#', color_r=255, color_g=255, color_b=255,
	block_move = true,
	block_sight = true,
}
