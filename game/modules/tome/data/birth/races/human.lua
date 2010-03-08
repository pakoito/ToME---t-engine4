---------------------------------------------------------
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Human",
	desc = {
		"The Edain are the humans are one of the youngest of the races of Arda.",
	},
	descriptor_choices =
	{
		subrace =
		{
			["Bree-man"] = "allow",
			Dunadan = "allow",
			Rohirrim = "allow",
			Beorning = "allow",
			__ALL__ = "never",
		},
	},
	talents = {},
	experience = 1.0,
	copy = {
		type = "humanoid", subtype="human",
	},
}

---------------------------------------------------------
--                       Humans                        --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Bree-man",
	desc = {
		"Humans hailing from the northen town of Bree. A common kind of man, unremarkable in all respects.",
	},
	copy = {
		default_wilderness = {"wilderness/main", 39, 19},
		starting_zone = "tower-amon-sul",
		starting_quest = "start-dunadan",
	},
}

newBirthDescriptor
{
	type = "subrace",
	name = "Dunadan",
	desc = {
		"The greatest of the Edain, humans in all respects but",
		"stronger, smarter and wiser.",
		"They posses the Gift of Kings which allows them to regenerate their wounds once in a while.",
	},
	stats = { str=1, cun=1, dex=1, wil=1 },
	experience = 1.25,
	talents = {
		[ActorTalents.T_IMPROVED_HEALTH_I]=1,
		[ActorTalents.T_DUNADAN_HEAL]=1,
	},
	copy = {
		default_wilderness = {"wilderness/main", 39, 19},
		starting_zone = "tower-amon-sul",
		starting_quest = "start-dunadan",
	},
}
--[[
newBirthDescriptor
{
	type = "subrace"
	name = "Rohirrim"
	desc = {
		"Humans from the land of Rohan, riding the great Mearas.",
	}
	stats = { [A_STR]=1, [A_INT]=1, [A_WIS]=0, [A_DEX]=3, [A_CON]=1, [A_CHR]=2, }
	experience = 70
	levels =
	{
		[ 1] = { SPEED=3 }
	}
	skills =
	{
		["Weaponmastery"]   = { mods.add(0)   , mods.add(200)  }
		["Riding"]          = { mods.add(5000), mods.add(600)  }
	}
}
newBirthDescriptor
{
	type = "subrace",
	name = "Beorning",
	desc = {
		"A race of men shapeshifters.",
		"They have the unique power of being able to polymorph to bear form.",
	},
	stats = { str=2, con=2, dex=-1, cun=-3, },
	experience = 1.8,
	talents = {},
}
]]
