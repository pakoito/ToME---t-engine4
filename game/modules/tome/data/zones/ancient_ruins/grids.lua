newEntity{
	define_as = "UP",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	change_level = -1
}

newEntity{
	define_as = "DOWN",
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	change_level = 1
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

newEntity{
	define_as = "DOOR",
	name = "door",
	display = '+', color_r=238, color_g=154, color_b=77,
	block_sight = true,
	door_opened = "DOOR_OPEN",
}

newEntity{
	define_as = "DOOR_OPEN",
	name = "open door",
	display = "'", color_r=238, color_g=154, color_b=77,
	block_move = false,
	block_sight = false,
	door_closed = "DOOR",
}
