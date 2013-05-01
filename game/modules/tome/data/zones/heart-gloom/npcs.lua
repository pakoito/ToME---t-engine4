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

local Talents = require("engine.interface.ActorTalents")

local alter

if not currentZone.is_purified then
	alter = function(add, mult)
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
else
	alter = function(add, mult)
		add = add or 0
		mult = mult or 1
		return function(e)
			if e.rarity then
				local list = {"T_PYROKINESIS", "T_DREAM_CRUSHER", "T_FORGE_SHIELD", "T_SOLIPSISM", "T_DREAM_WALK"}
				e[#e+1] = resolvers.talents{[ Talents[rng.table(list)] ] = {base=1, every=5, max=6}}
				e.rarity = math.ceil(e.rarity * mult + add)
				e.name = rng.table{"dreaming ", "slumbering ", "dozing "}..e.name
			end
		end
	end
end

load("/data/general/npcs/rodent.lua", alter(0))
load("/data/general/npcs/bear.lua", alter(3))
load("/data/general/npcs/canine.lua", alter(1))
load("/data/general/npcs/plant.lua", alter(0))

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
	tier1 = true,
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


newEntity{ define_as = "DREAMING_ONE",
	type = "horror", subtype = "eldritch",
	display = "h",
	unique = true,
	name = "The Dreaming One", tint=colors.PURPLE,
	color=colors.VIOLET, image = "npc/seed_of_dreams.png",
	desc = [[This strange globe of blue light seems to be alive and asleep. Nothing about it moves yet you can feel the crushing power of its dreams assaulting your mind.]],
	killer_message = "and absorbed into nightmares forever",
	level_range = {7, nil}, exp_worth = 2,
	max_life = 70, life_rating = 10, fixed_rating = true,
	stats = { str=10, dex=10, cun=20, wil=25, con=10 },
	rank = 4,
	tier1 = true,
	size_category = 2,
	infravision = 10,
	instakill_immune = 1,
	never_move = 1,

	combat = { dammod={wil=0.6, cun=0.4}, damtype=DamageType.MIND, dam=resolvers.levelup(8, 1, 0.9), atk=15, apr=3 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="EYE_OF_THE_DREAMING_ONE", random_art_replace={chance=75}} },
	resolvers.drops{chance=100, nb=3, {tome_drops="boss"} },

	resolvers.talents{
		[Talents.T_SOLIPSISM]=3,
		[Talents.T_FORGE_SHIELD]={base=2, every=4, max=6},
		[Talents.T_DISTORTION_BOLT]={base=1, every=4, max=6},
		[Talents.T_MINDHOOK]={base=4, every=4, max=6},
	},
	resolvers.sustains_at_birth(),

	autolevel = "wildcaster",
	ai = "tactical", ai_state = { talent_in=1 },

	on_die = function(self, who)
		game.player:resolveSource():setQuestStatus("start-thaloren", engine.Quest.COMPLETED, "heart-gloom")
		game.player:resolveSource():setQuestStatus("start-thaloren", engine.Quest.COMPLETED, "heart-gloom-purified")
	end,
}
