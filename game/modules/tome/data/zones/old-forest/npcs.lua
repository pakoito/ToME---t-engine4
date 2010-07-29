-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
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

load("/data/general/npcs/bear.lua")
load("/data/general/npcs/vermin.lua")
load("/data/general/npcs/canine.lua")
load("/data/general/npcs/snake.lua")
load("/data/general/npcs/swarm.lua")
load("/data/general/npcs/plant.lua")
load("/data/general/npcs/ant.lua")

load("/data/general/npcs/all.lua", function(e) if e.rarity then e.rarity = e.rarity * 20 end end)

local Talents = require("engine.interface.ActorTalents")

-- The boss of trollshaws, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "OLD_MAN_WILLOW",
	type = "giant", subtype = "huorn", unique = true,
	name = "Old Man Willow",
	display = "#", color=colors.OLIVE_DRAB,
	desc = [[The ancient grey willow tree, ruler of the Old Forest. He despises
	trespassers in his territory.  "...a huge willow-tree, old and hoary
	Enormous it looked, its sprawling branches going up like racing arms
	with may long-fingered hands, its knotted and twisted trunk gaping in
	wide fissures that creaked faintly as the boughs moved."]],
	level_range = {12, 35}, exp_worth = 2,
	max_life = 200, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	size_category = 5,
	infravision = 20,
	instakill_immune = 1,
	move_others=true,

	resists = { [DamageType.FIRE] = -50 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	equipment = resolvers.equip{ {type="armor", subtype="shield", defined="OLD_MAN_WILLOW_SHIELD", autoreq=true}, },
	drops = resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	resolvers.talents{
		[Talents.T_STAMINA_POOL]=1, [Talents.T_STUN]=2,

		[Talents.T_MANA_POOL]=1,
		[Talents.T_ICE_STORM]=1,
		[Talents.T_TIDAL_WAVE]=1,
		[Talents.T_FREEZE]=2,
	},

	autolevel = "caster",
	ai = "dumb_talented_simple", ai_state = { talent_in=3, ai_move="move_astar", },

	on_die = function(self, who)
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "old-forest")
	end,
}

newEntity{ base = "BASE_NPC_RODENT",
	name = "cute little bunny", color=colors.SALMON,
	desc = [[It looks at you with cute little eyes before jumping at you with razor sharp teeth.]],
	level_range = {1, 15}, exp_worth = 3,
	rarity = 200,
	max_life = resolvers.rngavg(15,20),
	combat = { dam=50, atk=15, apr=10 },
	combat_armor = 1, combat_def = 20,
}
