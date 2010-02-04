load("/data/general/objects/objects.lua")

-- Artifact, droped (and used!) by Bill the Stone Troll

newEntity{ base = "BASE_GREATMAUL",
	define_as = "GREATMAUL_BILL_TRUNK",
	name = "Bill's Tree Trunk", unique=true,
	desc = [[This ia big nasty looking tree trunk that Bill was using as a weapon. It could still serve this purpose, should you be strong enough to wield it!]],
	require = { stat = { str=25 }, },
	cost = 5,
	combat = {
		dam = 30,
		apr = 7,
		physcrit = 1.5,
		dammod = {str=1.3},
		damrange = 1.7,
	},

	wielder = {
	},
}
