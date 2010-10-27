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

load("/data/general/objects/objects-far-east.lua")
load("/data/general/objects/lore-sunwall.lua")

local Talents = require"engine.interface.ActorTalents"
local Stats = require"engine.interface.ActorStats"

newEntity{ base = "BASE_RING",
	define_as = "PRIDE_GLORY", rarity=false,
	name = "Glory of the Pride", unique=true,
	desc = [[The most prized treasure of the Battlemaster of the Pride, Grushnak. This gold ring is incribed in the orc tongue, the black speech.]],
	unided_name = "deep black ring",
	cost = 500,
	material_level = 5,
	wielder = {
		max_mana = -40,
		max_stamina = 40,
		stun_immune = 1,
		confusion_immune = 1,
		combat_atk = 10,
		combat_dam = 10,
		combat_def = 5,
		combat_armor = 10,
		fatigue = -15,
		talent_cd_reduction={
			[Talents.T_RUSH]=15,
		},
		inc_damage={ [DamageType.PHYSICAL] = 8, },
	},
}
