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

load("/data/general/npcs/xorn.lua")
load("/data/general/npcs/canine.lua", function(e) if e.rarity then e.rarity = e.rarity * 2 end end)
load("/data/general/npcs/snow-giant.lua")
load("/data/general/npcs/cold-drake.lua")

local Talents = require("engine.interface.ActorTalents")

-- The boss of trollshaws, no "rarity" field means it will not be randomly generated
newEntity{ define_as = "RANTHA_THE_WORM",
	type = "dragon", subtype = "ice", unique = true,
	name = "Rantha the Worm",
	display = "D", color=colors.VIOLET,
	desc = [[Claws and teeth. Ice and death. Dragons are not all extinct it seems...]],
	level_range = {12, 35}, exp_worth = 2,
	max_life = 230, life_rating = 17, fixed_rating = true,
	max_stamina = 85,
	max_mana = 200,
	stats = { str=25, dex=10, cun=8, mag=20, wil=20, con=20 },
	rank = 4,
	size_category = 5,
	combat_armor = 17, combat_def = 14,

	resists = { [DamageType.FIRE] = -20, [DamageType.COLD] = 100 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1 },
	resolvers.drops{chance=100, nb=1, {defined="FROST_TREADS"}, },
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },
	resolvers.drops{chance=100, nb=10, {type="money"} },

	resolvers.talents{
		[Talents.T_KNOCKBACK]=3,

		[Talents.T_ICE_STORM]=2,
		[Talents.T_FREEZE]=3,

		[Talents.T_ICE_CLAW]=4,
		[Talents.T_ICY_SKIN]=3,
		[Talents.T_ICE_BREATH]=4,
	},

	autolevel = "warriormage",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar", },

	on_die = function(self, who)
		game.player:resolveSource():grantQuest("starter-zones")
		game.player:resolveSource():setQuestStatus("starter-zones", engine.Quest.COMPLETED, "carn-dum")
	end,
}
