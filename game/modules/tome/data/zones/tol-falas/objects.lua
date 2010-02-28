load("/data/general/objects/objects.lua")

newEntity{ base = "BASE_AMULET",
	define_as = "AMULET_DREAD", rarity=false,
	name = "Choker of Dread", unique=true,
	unided_name = "dark amulet", color=colors.LIGHT_DARK,
	desc = [[The evilness of undeath radiates from this amulet.]],
	cost = 5000,
	wielder = {
		see_invisible = 10,
		blind_immune = 1,
		combat_spellpower = 5,
		combat_dam = 5,
	},
}
