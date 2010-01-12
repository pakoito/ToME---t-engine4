newEntity{
	define_as = "UP_WILDERNESS",
	name = "exit to the wilds",
	display = '<', color_r=255, color_g=0, color_b=255,
	always_remember = true,
	notice = true,
	change_level = 1,
	change_zone = "wilderness",
}

newEntity{
	define_as = "UP",
	name = "previous level",
	display = '<', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = -1,
}

newEntity{
	define_as = "DOWN",
	name = "next level",
	display = '>', color_r=255, color_g=255, color_b=0,
	notice = true,
	always_remember = true,
	change_level = 1,
}

newEntity{
	define_as = "FLOOR",
	name = "floor", image = "terrain/marble_floor.png",
	display = '.', color_r=255, color_g=255, color_b=255,
}

newEntity{
	define_as = "WALL",
	name = "wall", image = "terrain/granite_wall1.png",
	display = '#', color_r=255, color_g=255, color_b=255,
	always_remember = true,
	block_move = true,
	block_sight = true,
	dig = "FLOOR",
}

newEntity{
	define_as = "DOOR",
	name = "door", image = "terrain/granite_door1.png",
	display = '+', color_r=238, color_g=154, color_b=77,
	notice = true,
	always_remember = true,
	block_sight = true,
	door_opened = "DOOR_OPEN",
	dig = "DOOR_OPEN",
}

newEntity{
	define_as = "DOOR_OPEN",
	name = "open door", image = "terrain/granite_door1_open.png",
	display = "'", color_r=238, color_g=154, color_b=77,
	always_remember = true,
	block_move = false,
	block_sight = false,
	door_closed = "DOOR",
}

newEntity{
	define_as = "GRASS",
	name = "grass", image = "terrain/grass.png",
	display = '.', color=colors.LIGHT_GREEN,
}

newEntity{
	define_as = "FLOWER",
	name = "flower", image = "terrain/grass_flower3.png",
	display = ';', color=colors.YELLOW,
}

newEntity{
	define_as = "TREE",
	name = "tree", image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN,
	always_remember = true,
	block_move = true,
	block_sight = true,
	dig = "GRASS",
}
