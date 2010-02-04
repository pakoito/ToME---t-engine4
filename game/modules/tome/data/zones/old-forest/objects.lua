load("/data/general/objects/objects.lua")

-- Artifact, droped (and used!) by Bill the Stone Troll

newEntity{ base = "BASE_SHIELD",
	define_as = "OLD_MAN_WILLOW_SHIELD",
	name = "Old Man's Willow Barkwood", unique=true,
	desc = [[The barkwood of the Old Man's Willow, made into roughtly the shape of a shield.]],
	require = { stat = { str=25 }, },
	cost = 20,

	special_combat = {
		dam = resolvers.rngavg(20,30),
		physcrit = 2,
		dammod = {str=1.5},
	},
	wielder = {
		combat_armor = 5,
		combat_def = 9,
		fatigue = 14,
		resists = {
			[DamageType.FIRE] = -20,
			[DamageType.COLD] = 20,
			[DamageType.NATURE] = 20,
		},
	},
}
