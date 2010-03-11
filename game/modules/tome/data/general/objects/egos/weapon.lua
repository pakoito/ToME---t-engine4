newEntity{
	name = "flaming ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.FIRE] = resolvers.mbonus(25, 4)},
	},
}
newEntity{
	name = "icy ", prefix=true,
	level_range = {15, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.ICE] = resolvers.mbonus(15, 4)},
	},
}
newEntity{
	name = "acidic ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.ACID] = resolvers.mbonus(25, 4)},
	},
}
newEntity{
	name = "shocking ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.LIGHTNING] = resolvers.mbonus(25, 4)},
	},
}
newEntity{
	name = "poisonous ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.POISON] = resolvers.mbonus(45, 6)},
	},
}

newEntity{
	name = "slime-covered ", prefix=true,
	level_range = {10, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.SLIME] = resolvers.mbonus(45, 6)},
	},
}

newEntity{
	name = " of accuracy",
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat={atk = resolvers.mbonus(20, 2)},
}

newEntity{
	name = "kinetic ", prefix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 6,
	combat={apr = resolvers.mbonus(15, 1)},
}

newEntity{
	name = "elemental ", prefix=true,
	level_range = {35, 50},
	rarity = 25,
	cost = 35,
	wielder = {
		melee_project={
			[DamageType.FIRE] = resolvers.mbonus(25, 4),
			[DamageType.ICE] = resolvers.mbonus(15, 4),
			[DamageType.ACID] = resolvers.mbonus(25, 4),
			[DamageType.LIGHTNING] = resolvers.mbonus(25, 4),
		},
	},
}
