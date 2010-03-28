load("/data/general/npcs/orc.lua")

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC", define_as = "UKRUK",
	unique = true,
	name = "Ukruk the Fierce",
	color=colors.VIOLET,
	desc = [[This ugly orc looks really nasty and vicious. He is obviously looking for something and bears an unkown symbol on his shield.]],
	level_range = {50, 50}, exp_worth = 2,
	max_life = 15000, life_rating = 15, fixed_rating = true,

	resolvers.equip{
		{type="weapon", subtype="longsword", ego_chance=100, autoreq=true},
		{type="armor", subtype="shield", ego_chance=100, autoreq=true},
	},

	resolvers.talents{
		[Talents.T_SWORD_MASTERY]=10, [Talents.T_ASSAULT]=5, [Talents.T_OVERPOWER]=5,
	},

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
}
