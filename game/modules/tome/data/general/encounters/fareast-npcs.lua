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

class = require("mod.class.WorldNPC")

newEntity{
	name = "Sun Paladins patrol",
	type = "patrol", subtype = "sunwall",
	display = 'p', color = colors.GOLD,
	faction = "sunwall",
	level_range = {1, nil},
	sight = 4,
	rarity = 3,
	unit_power = 10,
	ai = "world_patrol", ai_state = {route_kind="sunwall"},
}

newEntity{
	name = "Anorithil patrol",
	type = "patrol", subtype = "sunwall",
	display = 'p', color = colors.YELLOW,
	faction = "sunwall",
	level_range = {1, nil},
	sight = 4,
	rarity = 3,
	unit_power = 10,
	ai = "world_patrol", ai_state = {route_kind="sunwall"},
}

newEntity{
	name = "Orcs patrol",
	type = "patrol", subtype = "orc pride",
	display = 'o', color = colors.GREY,
	faction = "orc-pride",
	level_range = {1, nil},
	sight = 4,
	rarity = 3,
	unit_power = 8,
	ai = "world_patrol", ai_state = {route_kind="orc-pride"},
	on_encounter = {type="ambush", width=14, height=14, nb={6,10}, filters={{type="humanoid", subtype="orc"}}},
}
