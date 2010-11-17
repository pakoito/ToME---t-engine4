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

load("/data/general/npcs/rodent.lua", rarity(5))
load("/data/general/npcs/vermin.lua", rarity(5))
load("/data/general/npcs/faeros.lua", rarity(2))
load("/data/general/npcs/gwelgoroth.lua", rarity(2))
load("/data/general/npcs/elven-caster.lua", rarity(2))

--load("/data/general/npcs/all.lua", rarity(4, 65))

local Talents = require("engine.interface.ActorTalents")

newEntity{ base = "BASE_NPC_ELVEN_CASTER", define_as = "GRAND_CORRUPTOR",
	allow_infinite_dungeon = true,
	name = "Grand Corruptor", color=colors.VIOLET, unique = true,
	desc = [[An elven corruptor, drawn to these blighted lands.]],
	level_range = {30, nil}, exp_worth = 1,
	rank = 3.5,
	vim_regen = 40,
	max_vim = 800,
	max_life = resolvers.rngavg(300, 310), life_rating = 18,
	resolvers.equip{
		{type="weapon", subtype="staff", autoreq=true},
		{type="armor", subtype="cloth", autoreq=true},
	},
	resolvers.drops{chance=100, nb=1, {unique=true} },
	resolvers.drops{chance=100, nb=3, {ego_chance=100} },

	combat_armor = 0, combat_def = 0,
	resolvers.talents{
		[Talents.T_BONE_SHIELD]=5,
		[Talents.T_BLOOD_SPRAY]=5,
		[Talents.T_SOUL_ROT]=5,
		[Talents.T_BLOOD_GRASP]=5,
		[Talents.T_BLOOD_BOIL]=5,
		[Talents.T_BLOOD_FURY]=5,
		[Talents.T_BONE_SPEAR]=5,
		[Talents.T_VIRULENT_DISEASE]=5,
		[Talents.T_DARKFIRE]=5,
		[Talents["T_FLAME_OF_URH'ROK"]]=5,
		[Talents.T_DEMON_PLANE]=5,
		[Talents.T_CYST_BURST]=4,
		[Talents.T_BURNING_HEX]=5,
		[Talents.T_WRAITHFORM]=5,
	},
	resolvers.sustains_at_birth(),
}
