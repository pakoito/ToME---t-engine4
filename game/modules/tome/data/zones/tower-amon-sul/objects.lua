load("/data/general/objects/objects.lua")

-- Artifact, droped (and used!) by the Shade of Angmar
newEntity{ base = "BASE_STAFF",
	define_as = "STAFF_ANGMAR",
	name = "Angmar's Fall", unique=true,
	require = { stat = { mag=25 }, },
	cost = 5,
	combat = {
		dam = 10,
		apr = 0,
		physcrit = 1.5,
		dammod = {mag=1.1},
	},
	wielder = {
		see_invisible = 2,
		combat_spellpower = 15,
		combat_spellcrit = 8,
	},
}
