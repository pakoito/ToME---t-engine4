---------------------------------------------------------
--                       Elves                         --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Elf",
	desc = {
		"Quendi are Elves, the first children of Eru.",
		"The first Elves awoke by Cuiviénen, the Water of Awakening in the far east of Middle-earth, long Ages before the Rising of the Sun or Moon.",
		"Unlike Men, the Elves are not subject to death by old age.",
	},
	descriptor_choices =
	{
		subrace =
		{
			Nandor = "allow",
			Avari = "allow",
			__ALL__ = "never",
		},
	},
	talents = {
--		[ActorTalents.T_IMPROVED_MANA_I]=1,
	},
	copy = {
		default_wilderness = {"wilderness/main", 41, 18},
	},
	experience = 1.05,
}

---------------------------------------------------------
--                       Elves                         --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Nandor",
	desc = {
		"Elves who turned aside from the Great Journey in the early days and settled in th east of the Misty Mountains.",
		"Both the Wood-Elves of Mirkwood and the Elves of Lórien are Nandor.",
	},
	stats = { str=-2, mag=2, wil=3, cun=1, dex=1, con=0 },
	experience = 1.3,
	talents = {},
}

newBirthDescriptor
{
	type = "subrace",
	name = "Avari",
	desc = {
		"The Avari are those elves who refused the summons of Orome to come to Valinor, and stayed behind in Middle-earth instead.",
	},
	stats = { str=-1, mag=1, wil=1, cun=3, dex=2, con=0 },
	talents = { ActorTalents.DECREASED_HEALTH_I },
	experience = 1.1,
}
