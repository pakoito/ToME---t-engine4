-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

local Talents = require("engine.interface.ActorTalents")

local gloomify = function(add, mult)
	add = add or 0
	mult = mult or 1
	return function(e)
		if e.rarity then
			local list = {"T_GLOOM", "T_AGONY", "T_REPROACH", "T_DARK_TENDRILS", "T_BLINDSIDE"}
			e[#e+1] = resolvers.talents{[ Talents[rng.table(list)] ] = {base=1, every=5, max=6}}
			e.rarity = math.ceil(e.rarity * mult + add)
			e.name = rng.table{"gloomy ", "deformed ", "sick "}..e.name
		end
	end
end

load("/data/general/npcs/rodent.lua", gloomify(0))
load("/data/general/npcs/bear.lua", gloomify(3))
load("/data/general/npcs/canine.lua", gloomify(1))
load("/data/general/npcs/plant.lua", gloomify(0))

--load("/data/general/npcs/all.lua", rarity(4, 35))

newEntity{ base="BASE_NPC_CANINE", define_as = "WITHERING_THING",
	unique = true,
	name = "The Withering Thing", tint=colors.PURPLE,
	color=colors.VIOLET,
	desc = [[This deformed beast might have been a wolf before, but now it is just.. terrible.]],
	killer_message = "and corrupted into a pile of writhing worms",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 100, life_rating = 15, fixed_rating = true,
	stats = { str=20, dex=20, cun=12, wil=20, con=10 },
	rank = 4,
	size_category = 3,
	infravision = 10,
	instakill_immune = 1,

	combat = { dam=resolvers.levelup(8, 1, 0.9), atk=15, apr=3 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="WITHERING_ORBS", random_art_replace={chance=75}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_BLINDSIDE]=2,
		[Talents.T_CALL_SHADOWS]={base=3, every=4, max=6},
		[Talents.T_SHADOW_MAGES]={base=1, every=4, max=6},
		[Talents.T_SHADOW_WARRIORS]={base=1, every=4, max=6},
	},
	resolvers.sustains_at_birth(),

	autolevel = "warriorwill",
	ai = "tactical", ai_state = { talent_in=2 },
	ai_tactic = resolvers.tactic"melee",

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-thaloren", engine.Quest.COMPLETED, "heart-gloom")
	end,
}
