---------------------------------------------------------
--                       Humans                        --
---------------------------------------------------------
--[[
newBirthDescriptor
{
	type = "subrace",
	name = "Human",
	desc = {
		"Humans are one of the youngest of the races of Arda.",
	},
}
]]
newBirthDescriptor
{
	type = "subrace",
	name = "Dunadan",
	desc = {
		"The greatest of the Edain, humans in all respects but",
		"stronger, smarter and wiser.",
	},
	stats = { str=1, cun=1, dex=1, wil=1 },
	experience = 1.1,
	talents = { [ActorTalents.T_IMPROVED_HEALTH_I]=1, [ActorTalents.T_DUNADAN_HEAL]=1, },
	copy = {
		default_wilderness = {"wilderness/rhudaur", 9, 4},
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

---------------------------------------------------------
--                       Elves                         --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Noldor",
	desc = {
		"The Noldor are the second clan of Elves who came to Valinor, and ",
		"are accounted as the greatest of all peoples in Middle-earth. ",
		"They are masters of all skills, and are strong and intelligent. ",
		"They can play all classes except rogues, and very well at that. ",
		"High-elves begin their lives able to see the unseen, and resist ",
		"light effects just like regular elves.  However, there are few ",
		"things that they have not seen already, and experience is very ",
		"hard for them to gain."
	},
	stats = { str=1, mag=2, wil=3, cun=1, dex=1, },
	experience = 1.3,
	talents = {},
}

newBirthDescriptor
{
	type = "subrace",
	name = "Avari",
	desc = {
		"The Avari are those elves who refused the summons of Orome to come",
		"to Valinor, and stayed behind in Middle-earth instead.  While ",
		"somewhat less hardy than the Noldor, they are better at magic, ",
		"gain experience faster, and have an intrinsic magic missile ",
		"attack.  Unlike the Noldor, they are resistant to darkness attacks ",
		"rather than light attacks, and gain the ability to see invisible ",
		"things at a higher level, rather than starting out with it."
	},
	stats = { str=-1, dex=2, cun=2, mag=1, },
	talents = { ActorTalents.DECREASED_HEALTH_I },
	experience = 1.1,
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

---------------------------------------------------------
--                        Ents                         --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Ent",
	desc = {
		"Guardian of the forests of Middle-earth, summoned by Yavanna before",
		"even the elves awoke. It is said 'Trolls are strong, Ents are STRONGER'.",
		"Ent-wives went away a long time ago and as such may not be played."
	},
}
