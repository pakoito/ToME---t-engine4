newEntity{
	define_as = "SAND",
	name = "sand", image = "terrain/sand.png",
	display = '.', color={r=203,g=189,b=72},
}

newEntity{
	define_as = "SANDWALL",
	name = "sandwall", image = "terrain/sandwall.png",
	display = '#', color={r=203,g=189,b=72},
	always_remember = true,
	block_move = true,
	block_sight = true,
	dig = "SAND",
}
