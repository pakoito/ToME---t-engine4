newEntity{
	name = " of fire resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus(20, 10)},
	},
}
newEntity{
	name = " of cold resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus(20, 10)},
	},
}
newEntity{
	name = " of acid resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus(20, 10)},
	},
}
newEntity{
	name = " of lightning resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.LIGHTNING] = resolvers.mbonus(20, 10)},
	},
}
newEntity{
	name = " of nature resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.NATURE] = resolvers.mbonus(20, 10)},
	},
}


newEntity{
	name = "flaming ", prefix=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.FIRE] = resolvers.mbonus(7, 3)},
	},
}
newEntity{
	name = "icy ", prefix=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 10,
	wielder = {
		on_melee_hit={[DamageType.ICE] = resolvers.mbonus(4, 3)},
	},
}
newEntity{
	name = "acidic ", prefix=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.ACID] = resolvers.mbonus(7, 3)},
	},
}
newEntity{
	name = "shocking ", prefix=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.LIGHTNING] = resolvers.mbonus(7, 3)},
	},
}

newEntity{
	name = " of deflection",
	level_range = {10, 50},
	rarity = 15,
	cost = 20,
	wielder = {
		combat_def=resolvers.mbonus(15, 4),
	},
}

newEntity{
	name = " of resilience",
	level_range = {20, 50},
	rarity = 15,
	cost = 20,
	wielder = {
		max_life=resolvers.mbonus(100, 10),
	},
}
