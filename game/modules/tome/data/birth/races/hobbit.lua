---------------------------------------------------------
--                       Hobbits                       --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Hobbit",
	desc = {
		"Hobbits, or halflings, are a race of very short stature, rarely exceeded four feet in height.",
		"Most of them are happy to live a quiet life farming and gardening, but a few get an adventurous heart.",
		"Hobbits are agile, lucky and resilient but lack in strength.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "never",
			Hobbit = "allow",
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
		default_wilderness = {"wilderness/main", 39, 17},
		starting_zone = "tower-amon-sul",
		starting_quest = "start-dunadan",
		starting_intro = "hobbit",
	},
}

---------------------------------------------------------
--                       Hobbits                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Hobbit",
	desc = {
		"Hobbits, or halflings, are a race of very short stature, rarely exceeded four feet in height.",
		"Most of them are happy to live a quiet life farming and gardening, but a few get an adventurous heart.",
		"Hobbits are agile, lucky and resilient but lack in strength.",
	},
}
