---------------------------------------------------------
--                       Dwarves                       --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Dwarf",
	desc = {
		"The children of Aule, a strong but small race.",
		"Miners and fighters of legend.",
		"Female dwarves remain a mystery and as such may not be played."
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "never",
			Dwarf = "allow",
		},
		sex =
		{
			__ALL__ = "never",
			Male = "allow",
		},
	},
	stats = { str=4, con=3, wil=3, mag=-2, dex=-2 },
	talents = {
		[ActorTalents.T_DWARF_RESILIENCE]=1,
	},
	copy = {
		default_wilderness = {"wilderness/main", 41, 18},
	},
	life_rating=12,
	experience = 1.1,
}

---------------------------------------------------------
--                       Dwarves                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Dwarf",
	desc = {
		"The children of Aule, a strong but small race.",
		"Miners and fighters of legend.",
	},
}
