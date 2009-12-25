newBirthDescriptor{
	type = "race",
	name = "Human",
	desc = {
		"Humans are one of the youngest of the races of Arda.",
	},
	descriptor_choices =
	{
		subrace =
		{
			Human = "allow",
			Dunadan = "allow",
			Rohirrim = "allow",
			Beorning = "allow",
			__ALL__ = "never",
		},
	},
	stats = { cun=1 },
	talents = {},
	experience = 1.0,
}
--[[
newBirthDescriptor{
	type = "race",
	name = "Elf",
	desc = {
		"Elves are the first children of Eru.",
		"The first Elves awoke by Cuiviénen, the Water of Awakening in the far east of Middle-earth, long Ages before the Rising of the Sun or Moon. Unlike Men, the Elves were not subject to illness or death.",
	},
	descriptor_choices =
	{
		subrace =
		{
			Noldor = "allow",
			Avari = "allow",
			__ALL__ = "never",
		},
	},
	stats = { wil=1, mag=1, },
	talents = {
		ActorTalents.T_IMPROVED_MANA_I,
	},
	experience = 1.05,
}

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
	stats = { str=1, con=1 },
	talents = {
		ActorTalents.T_IMPROVED_HEALTH_I,
	},
	experience = 1.05,
}

newBirthDescriptor{
	type = "race",
	name = "Hobbit",
	desc = {
		"Hobbits, or halflings, are very good at ranged combat ",
		"(especially with slings), throwing, and have good saving ",
		"throws. They also are very good at searching, disarming, ",
		"perception and stealth; so they make excellent rogues, but ",
		"prefer to be called burglars.  They are much weaker than ",
		"humans, thus not as good at melee fighting, and also not ",
		"capable of carrying as many objects.  Halflings have fair ",
		"infra-vision, so they can detect warm creatures at a ",
		"distance. Hobbits have their dexterity sustained and in time ",
		"they learn to cook a delicious meal from available ",
		"ingredients.  Their sturdy constitutions also allow them to ",
		"resist the insidious poison of the ring-wraiths.  Their feet ",
		"are cover from the ankle down in brown hairy fur, preventing ",
		"them from wearing boots and shoes. ",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "never",
			Harfoot = "allow",
			Stoor = "allow",
			Fallohide = "allow",
		},
	},
	stats = { str=-3, dex=3, con=2, lck=5, },
	experience = 1.1,
	talents = {
		ActorTalents.T_IMPROVED_HEALTH_I,
		ActorTalents.T_IMPROVED_HEALTH_II,
	},
}
]]