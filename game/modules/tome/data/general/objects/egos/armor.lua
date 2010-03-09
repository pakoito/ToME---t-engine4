newEntity{
	name = " of fire resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus(30, 10)},
	},
}
newEntity{
	name = " of cold resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus(30, 10)},
	},
}
newEntity{
	name = " of acid resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus(30, 10)},
	},
}
newEntity{
	name = " of lightning resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.LIGHTNING] = resolvers.mbonus(30, 10)},
	},
}
newEntity{
	name = " of nature resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.NATURE] = resolvers.mbonus(30, 10)},
	},
}

newEntity{
	name = " of stability",
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		stun_immune = 0.7,
		knockback_immune = 0.7,
	},
}
