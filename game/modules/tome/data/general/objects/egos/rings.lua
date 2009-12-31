local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"

newEntity{
	name = " of see invisible",
	level_range = {1, 20},
	rarity = 4,
	cost = 2,
	wielder = {
		see_invisible = resolvers.mbonus(20, 5),
	},
}

newEntity{
	name = " of invisibility",
	level_range = {30, 40},
	rarity = 4,
	cost = 16,
	wielder = {
		invisible = resolvers.mbonus(10, 5),
	},
}

newEntity{
	name = " of regeneration",
	level_range = {10, 20},
	rarity = 10,
	cost = 8,
	wielder = {
		life_regen = resolvers.mbonus(3, 1),
	},
}

newEntity{
	name = "energizing ", prefix=true,
	level_range = {10, 20},
	rarity = 8,
	cost = 3,
	wielder = {
		mana_regen = resolvers.mbonus(3, 1),
	},
}

newEntity{
	name = " of accuracy",
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_atk = resolvers.mbonus(15, 5),
	},
}

newEntity{
	name = " of defense",
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_defense = resolvers.mbonus(15, 5),
	},
}

newEntity{
	name = " of fire resistance",
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.FIRE] = resolvers.mbonus(15, 20), }
	},
}

newEntity{
	name = " of cold resistance",
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.COLD] = resolvers.mbonus(15, 20), }
	},
}

newEntity{
	name = " of nature resistance",
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.NATURE] = resolvers.mbonus(15, 20), }
	},
}

newEntity{
	name = " of lightning resistance",
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.LIGHTNING] = resolvers.mbonus(15, 20), }
	},
}

newEntity{
	name = " of acid resistance",
	level_range = {10, 40},
	rarity = 6,
	cost = 2,
	wielder = {
		resists = { [DamageType.ACID] = resolvers.mbonus(15, 20), }
	},
}

newEntity{
	name = " of spell resistance",
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_spellresist = resolvers.mbonus(15, 5),
	},
}

newEntity{
	name = " of physical resistance",
	level_range = {1, 30},
	rarity = 6,
	cost = 2,
	wielder = {
		combat_spellresist = resolvers.mbonus(15, 5),
	},
}

newEntity{
	name = " of strength",
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		stats = { [Stats.STAT_STR] = resolvers.mbonus(8, 2) },
	},
}
newEntity{
	name = " of dexterity",
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		stats = { [Stats.STAT_DEX] = resolvers.mbonus(8, 2) },
	},
}
newEntity{
	name = " of magic",
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		stats = { [Stats.STAT_MAG] = resolvers.mbonus(8, 2) },
	},
}
newEntity{
	name = " of constitution",
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		stats = { [Stats.STAT_CON] = resolvers.mbonus(8, 2) },
	},
}
