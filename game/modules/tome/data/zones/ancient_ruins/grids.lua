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
--	color_br=55, color_bg=125, color_bb=5,
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

newEntity{
	define_as = "1",
	name = "1",
	display = '1', color_r=255, color_g=255, color_b=0,
}
newEntity{
	define_as = "2",
	name = "2",
	display = '2', color_r=255, color_g=255, color_b=0,
}
newEntity{
	define_as = "3",
	name = "3",
	display = '3', color_r=255, color_g=255, color_b=0,
}
newEntity{
	define_as = "4",
	name = "4",
	display = '4', color_r=255, color_g=255, color_b=0,
}
newEntity{
	define_as = "5",
	name = "5",
	display = '5', color_r=255, color_g=255, color_b=0,
}
newEntity{
	define_as = "6",
	name = "6",
	display = '6', color_r=255, color_g=255, color_b=0,
}
newEntity{
	define_as = "7",
	name = "7",
	display = '7', color_r=255, color_g=255, color_b=0,
}
newEntity{
	define_as = "8",
	name = "8",
	display = '8', color_r=255, color_g=255, color_b=0,
}
newEntity{
	define_as = "9",
	name = "9",
	display = '9', color_r=255, color_g=255, color_b=0,
}
