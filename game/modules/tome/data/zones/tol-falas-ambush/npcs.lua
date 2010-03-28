load("/data/general/npcs/orc.lua")

local Talents = require("engine.interface.ActorTalents")

-- The boss of Amon Sul, no "rarity" field means it will not be randomly generated
newEntity{ base="BASE_NPC_ORC", define_as = "SHADE_OF_ANGMAR",
	unique = true,
	name = "Ukruk the Fierce",
	color=colors.VIOLET,
	desc = [[This ugly orc looks really nasty and vicious. He is obviously looking for something and bears an unkown symbol on his shield.]],
	level_range = {20, 50}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,

	resolvers.equip{ {type="weapon", subtype="staff", defined="STAFF_ANGMAR"}, {type="armor", subtype="light"}, },

	resolvers.talents{
		[Talents.T_MANA_POOL]=1, [Talents.T_MANATHRUST]=4, [Talents.T_FREEZE]=4, [Talents.T_TIDAL_WAVE]=2,
		[Talents.T_STAMINA_POOL]=1, [Talents.T_SWORD_MASTERY]=3, [Talents.T_STUNNING_BLOW]=1,
	},

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=4, },
}
