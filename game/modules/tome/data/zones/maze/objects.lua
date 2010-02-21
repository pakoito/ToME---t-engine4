load("/data/general/objects/objects.lua")

local Stats = require"engine.interface.ActorStats"

-- Artifact, droped (and used!) by the Minautaur
newEntity{ base = "BASE_HELM",
	define_as = "HELM_OF_HAMMERHAND",
	name = "Steel Helm of Hammerhand", unique=true,
	desc = [[A great helm as steady as the heroes of the Westdike. Mighty were the blows of Helm, the Hammerhand!]],
	require = { stat = { str=16 }, },
	cost = 20,

	wielder = {
		combat_armor = 3,
		fatigue = 8,
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_CON] = 3, [Stats.STAT_WIL] = 4 },
		combat_physresist = 7,
		combat_mentalresist = 7,
		combat_spellresist = 7,
	},
}
