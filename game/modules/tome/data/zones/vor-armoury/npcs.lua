-- ToME - Tales of Maj'Eyal
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

load("/data/general/npcs/orc.lua", rarity(3))
load("/data/general/npcs/orc-vor.lua", rarity(0))
load("/data/general/npcs/orc-grushnak.lua", rarity(4))
load("/data/general/npcs/bone-giant.lua", rarity(4))

load("/data/general/npcs/all.lua", rarity(4, 35))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base="BASE_NPC_ORC_GRUSHNAK", define_as = "GNARG",
	name = "Warmaster Gnarg", color=colors.VIOLET, unique = true,
	desc = [[This ugly orc looks really nasty and vicious. He wields a huge two-handed sword and means to use it.]],
	level_range = {35, nil}, exp_worth = 2,
	rank = 4,
	max_life = 250, life_rating = 27, fixed_rating = true,
	infravision = 20,
	stats = { str=22, dex=20, cun=12, mag=21, con=14 },
	move_others=true,

	instakill_immune = 1,
	stun_immune = 1,
	blind_immune = 1,
	combat_spellresist = 30,
	combat_physresist = 50,

	combat_armor = 10, combat_def = 10,

	open_door = true,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=1, ai_move="move_astar", },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, HEAD=1 },

	resolvers.equip{
		{type="weapon", subtype="greatsword", defined="MURDERBLADE", autoreq=true},
		{type="armor", subtype="massive", ego_change=100, autoreq=true},
	},
	resolvers.drops{chance=100, nb=5, {ego_chance=100} },

	-- Reduce cooldowns
	talent_cd_reduction={[Talents.T_RUSH]=35,},

	resolvers.talents{
		[Talents.T_RUSH]=5,
		[Talents.T_WARSHOUT]=5,
		[Talents.T_STUNNING_BLOW]=5,
		[Talents.T_SUNDER_ARMOUR]=5,
		[Talents.T_SLOW_MOTION]=5,
		[Talents.T_SHATTERING_SHOUT]=5,
		[Talents.T_SECOND_WIND]=5,
	},
	resolvers.sustains_at_birth(),
}
