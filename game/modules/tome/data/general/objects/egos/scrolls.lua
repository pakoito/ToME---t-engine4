newEntity{
	name = "fire-proof ", prefix=true,
	level_range = {1, 50},
	rarity = 4,
	cost = 0.5,
	fire_proof = true,
}

newEntity{
	name = "long ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 2,
	multicharge = resolvers.mbonus(4, 2),
}
