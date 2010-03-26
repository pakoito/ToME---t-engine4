newEntity{
	define_as = "GRASS",
	name = "grass", image = "terrain/grass.png",
	display = '.', color=colors.LIGHT_GREEN,
}

newEntity{
	define_as = "TREE",
	name = "tree", image = "terrain/tree.png",
	display = '#', color=colors.LIGHT_GREEN,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "GRASS",
}

newEntity{
	define_as = "GRASS_DARK1",
	name = "grass", image = "terrain/grass_dark1.png",
	display = '.', color=colors.GREEN,
}

newEntity{
	define_as = "TREE_DARK1",
	name = "tree", image = "terrain/tree_dark1.png",
	display = '#', color=colors.GREEN,
	always_remember = true,
	can_pass = {pass_tree=1},
	does_block_move = true,
	block_sight = true,
	dig = "GRASS_DARK1",
}

newEntity{
	define_as = "FLOWER",
	name = "flower", image = "terrain/grass_flower3.png",
	display = ';', color=colors.YELLOW,
}
