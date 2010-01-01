load("/data/general/npcs/vermin.lua")
load("/data/general/npcs/molds.lua")
load("/data/general/npcs/skeleton.lua")

local Talents = require("engine.interface.ActorTalents")

-- The boss of Amon Sul, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "SHADE_OF_ANGMAR",
	type = "undead", subtype = "skeleton", unique = true,
	name = "The Shade of Angmar",
	display = "s", color=colors.VIOLET,
	desc = [[This skeleton looks nasty. There is red flames in its empty eye sockets. It wield a nasty sword and towers toward you, throwing spells.]],
	level_range = {7, 10}, exp_worth = 2,
	max_life = 150, life_rating = 15, fixed_rating = true,
	max_mana = 85,
	stats = { str=15, dex=12, cun=14, mag=16, con=16 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{ {type="weapon", subtype="longsword"}, {type="armor", subtype="light"}, },
	drops = resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	talents = resolvers.talents{ Talents.T_MANA_POOL, Talents.T_MANATHRUST, Talents.T_FREEZE, Talents.T_TIDAL_WAVE },

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=4, },
}
