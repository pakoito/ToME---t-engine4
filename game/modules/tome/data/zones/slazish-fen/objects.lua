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

load("/data/general/objects/objects-far-east.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

for i = 1, 3 do
newEntity{ base = "BASE_LORE",
	define_as = "SLAZISH_NOTE"..i,
	name = "weird conch", lore="slazish-note-"..i, image = "terrain/shell1.png",
	desc = [[A conch, it seemed the naga was using it as a communication tool.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_CLOTH_ARMOR", define_as = "ROBES_DEFLECTION",
	power_source = {arcane=true},
	unique = true,
	name = "Robes of Deflection", color = colors.UMBER, image = "object/artifact/robes_of_deflection.png",
	unided_name = "iridescent robe",
	desc = [[This set of robes seems to shine with metallic colors.]],
	level_range = {1, 10},
	rarity = false,
	cost = 70,
	material_level = 1,
	wielder = {
		combat_armor_hardiness = 30,
		combat_armor = 7,
		inc_stats = { [Stats.STAT_CON] = 3, [Stats.STAT_MAG] = 3, },
		combat_spellpower = 4,
	},
	talent_on_spell = { {chance=4, talent=Talents.T_EVASION, level=1} },
}
