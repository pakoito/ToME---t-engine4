---------------------------------------------------------
--                       Hobbits                       --
---------------------------------------------------------
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
	stats = { str=-3, dex=3, con=1, cun=3, lck=5, },
	experience = 1.1,
	talents = {
		[ActorTalents.T_HOBBIT_LUCK]=1,
	},
	copy = {
		type = "humanoid", subtype="hobbit",
		life_rating = 12,
		default_wilderness = {"wilderness/main", 39, 19},
		starting_zone = "tower-amon-sul",
		starting_quest = "start-dunadan",
	},
}

---------------------------------------------------------
--                       Hobbits                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Harfoot",
	desc = {
		"An old but quiet race related to humans.",
		"They are small and quite weak but good at many things.",
	},
}
newBirthDescriptor
{
	type = "subrace",
	name = "Fallohide",
	desc = {
		"An old but quiet race related to humans.",
		"They are small and quite weak but good at many things.",
	},
}
newBirthDescriptor
{
	type = "subrace",
	name = "Stoor",
	desc = {
		"An old but quiet race related to humans.",
		"They are small and quite weak but good at many things.",
	},
}
