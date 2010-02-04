local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"

newEntity{
	name = " of cunning (#STATBONUS#)",
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus(8, 2) },
	},
}
newEntity{
	name = " of willpower (#STATBONUS#)",
	level_range = {1, 50},
	rarity = 6,
	cost = 4,
	wielder = {
		inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus(8, 2) },
	},
}
newEntity{
	name = " of mastery (#MASTERY#)",
	level_range = {1, 50},
	rarity = 3,
	cost = 2,
	wielder = {},
	resolvers.generic(function(e)
		local tts = {
			"cunning/dirty",
			"cunning/stealth",
			"cunning/survival",

			"spell/air",
			"spell/arcane",
			"spell/conveyance",
			"spell/divination",
			"spell/earth",
			"spell/fire",
			"spell/meta",
			"spell/nature",
			"spell/necromancy",
			"spell/phantasm",
			"spell/temporal",
			"spell/water",

			"technique/2hweapon-cripple",
			"technique/2hweapon-offense",
			"technique/combat-techniques-active",
			"technique/combat-techniques-passive",
			"technique/combat-training",
			"technique/dualweapon-attack",
			"technique/dualweapon-training",
			"technique/shield-defense",
			"technique/shield-offense",
		}
		local tt = tts[rng.range(1, #tts)]

		e.wielder.talents_types_mastery = {}
		e.wielder.talents_types_mastery[tt] = (10 + rng.mbonus(30, resolvers.current_level, 50)) / 100
	end),
}
newEntity{
	name = " of greater telepathy",
	level_range = {40, 50},
	rarity = 15,
	cost = 15,
	wielder = {
		esp = {all=1},
	},
}
newEntity{
	name = " of telepathic range",
	level_range = {40, 50},
	rarity = 15,
	cost = 15,
	wielder = {
		esp = {range=10},
	},
}
