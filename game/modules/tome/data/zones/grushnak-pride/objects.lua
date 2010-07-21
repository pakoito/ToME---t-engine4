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

load("/data/general/objects/objects.lua")

local Stats = require"engine.interface.ActorStats"

newEntity{ base = "BASE_MASSIVE_ARMOR",
	define_as = "BLACK_ROBE", rarity=false,
	name = "mithril plate armour", unique=true,
	unided_name = "massive armour",
	require = { stat = { str=60 }, },
	cost = 50,
	material_level = 5,
	wielder = {
		combat_def = 9,
		combat_armor = 16,
		fatigue = 26,
	},
}
