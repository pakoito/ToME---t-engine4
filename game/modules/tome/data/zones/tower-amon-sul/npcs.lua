load("/data/general/npcs/vermin.lua")
load("/data/general/npcs/molds.lua")
load("/data/general/npcs/skeleton.lua")

local Talents = require("engine.interface.ActorTalents")

-- The boss of Amon Sul, no "rarity" field means it will not be randomly generated
newEntity{ base = "BASE_NPC_SKELETON", define_as = "SHADE_OF_ANGMAR",
	unique = true,
	name = "The Shade of Angmar", color=colors.VIOLET,
	desc = [[This skeleton looks nasty. There is red flames in its empty eye sockets. It wield a nasty sword and towers toward you, throwing spells.]],
	level_range = {6, 10}, exp_worth = 1,
	max_life = 150, fixed_rating = true,
	max_mana = 85,
	combat_armor = 3, combat_def = 1,
	stats = { str=10, dex=12, cun=14, mag=14, con=10 },

	talents = resolvers.talents{ Talents.T_MANA_POOL, Talents.T_FREEZE, Talents.T_TIDAL_WAVE },

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, },
}
