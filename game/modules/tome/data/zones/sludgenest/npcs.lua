-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

load("/data/general/npcs/jelly.lua", rarity(0))
load("/data/general/npcs/ooze.lua", rarity(0))

local Talents = require("engine.interface.ActorTalents")

newEntity{ define_as = "CORRUPTED_OOZEMANCER",
	allow_infinite_dungeon = true,
	type = "giant", subtype = "troll", unique = true,
	name = "Corrupted Oozemancer",
	display = "T", color=colors.VIOLET,
	desc = [[This blight-ridden troll was once a pround defender of Nature. His corruption is spreading, eating away at the forest around him.]],
	killer_message = "and dissolved into acidic ooze",
	level_range = {35, nil}, exp_worth = 2,
	max_life = 250, life_rating = 18, fixed_rating = true,
	equilibrium_regen = -10,
	stats = { str=25, dex=10, cun=8, mag=10, con=20 },
	rank = 4,
	size_category = 4,
	infravision = 10,
	instakill_immune = 1,
	move_others=true,

	combat_mindcrit = -28,

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.equip{ {type="weapon", subtype="mindstar", forbid_power_source={antimagic=true}, autoreq=true}, },
	resolvers.equip{ {type="weapon", subtype="mindstar", forbid_power_source={antimagic=true}, autoreq=true}, },
	resolvers.equip{ {type="armor", subtype="cloth", forbid_power_source={antimagic=true}, autoreq=true}, },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_GRASPING_MOSS]={base=4, every=4, max=8},
		[Talents.T_SLIPPERY_MOSS]={base=4, every=4, max=8},
		[Talents.T_MITOSIS]={base=5, every=4, max=8},
		[Talents.T_REABSORB]={base=4, every=4, max=8},
		[Talents.T_CALL_OF_THE_OOZE]={base=4, every=4, max=8},
		[Talents.T_INDISCERNIBLE_ANATOMY]=5,
		[Talents.T_MUCUS]={base=4, every=4, max=8},
		[Talents.T_ACID_SPLASH]={base=3, every=5, max=8},
		[Talents.T_LIVING_MUCUS]={base=4, every=4, max=8},
		[Talents.T_SLIME_SPIT]={base=4, every=4, max=8},
		[Talents.T_MUCUS]={base=4, every=4, max=8},
		[Talents.T_ACIDIC_SKIN]={base=4, every=4, max=8},
		[Talents.T_OOZEBEAM]={base=4, every=4, max=8},
		[Talents.T_ACIDBEAM]={base=4, every=4, max=8},
		[Talents.T_NATURAL_ACID]={base=4, every=4, max=8},
		[Talents.T_CORROSIVE_NATURE]={base=4, every=4, max=8},
		[Talents.T_PSIBLADES]={base=4, every=4, max=8},
		[Talents.T_CORROSIVE_SEEDS]={base=4, every=4, max=8},
		[Talents.T_MIND_PARASITE]={base=4, every=4, max=8},
		[Talents.T_UNSTOPPABLE_NATURE]={base=4, every=4, max=8},
		[Talents.T_ACIDIC_SOIL]={base=4, every=4, max=8},
		[Talents.T_BLIGHTED_SUMMONING]=1,
	},
	resolvers.inscriptions(3, "infusion"),

	autolevel = "wildcaster",
	ai = "tactical", ai_state = { talent_in=1, ai_move="move_astar", },

	on_die = function(self, who)
		world:gainAchievement("OOZEMANCER", game.player)
		game:setAllowedBuild("wilder", false)
		game:setAllowedBuild("wilder_oozemancer", true)
	end,
}

