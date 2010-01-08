local Stats = require "engine.interface.ActorStats"

newEntity{
	name = " of power",
	level_range = {1, 50},
	rarity = 4,
	cost = 5,
	wielder = {
		combat_spellpower = resolvers.mbonus(30, 3),
	},
}

newEntity{
	name = "charged ", prefix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 5,
	wielder = {
		max_mana = resolvers.mbonus(100, 10),
	},
}

newEntity{
	name = " of wizardry",
	level_range = {25, 50},
	rarity = 4,
	cost = 5,
	wielder = {
		combat_spellpower = resolvers.mbonus(30, 3),
		max_mana = resolvers.mbonus(100, 10),
		inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus(5, 1), [Stats.STAT_WIL] = resolvers.mbonus(5, 1) },
	},
}
