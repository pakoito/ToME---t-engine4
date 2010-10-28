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

class = require("mod.class.WorldNPC")

newEntity{
	name = "Allied Kingdoms human patrol",
	type = "patrol", subtype = "allied kingdoms", cant_be_moved=true,
	display = 'p', color = colors.LIGHT_UMBER,
	faction = "allied-kingdoms",
	level_range = {1, nil},
	sight = 4,
	rarity = 3,
	unit_power = 10,
	ai = "world_patrol", ai_state = {route_kind="allied-kingdoms"},
}

newEntity{
	name = "Allied Kingdoms halfling patrol",
	type = "patrol", subtype = "allied kingdoms", cant_be_moved=true,
	display = 'p', color = colors.UMBER,
	faction = "allied-kingdoms",
	level_range = {1, nil},
	sight = 4,
	rarity = 3,
	unit_power = 10,
	ai = "world_patrol", ai_state = {route_kind="allied-kingdoms"},
}

newEntity{
	name = "lone bear",
	type = "hostile", subtype = "animal", cant_be_moved=true,
	display = 'q', color = colors.UMBER,
	level_range = {1, nil},
	sight = 3,
	rarity = 4,
	unit_power = 1,
	ai = "world_hostile", ai_state = {chase_distance=3},
	on_encounter = {type="ambush", width=10, height=10, nb={1,1}, filters={{type="animal", subtype="bear"}}},
}

newEntity{
	name = "pack of wolves",
	type = "hostile", subtype = "animal", cant_be_moved=true,
	display = 'c', color = colors.RED, image="npc/canine_w.png",
	level_range = {1, nil},
	sight = 3,
	rarity = 4,
	unit_power = 1,
	ai = "world_hostile", ai_state = {chase_distance=3},
	on_encounter = {type="ambush", width=10, height=10, nb={3,5}, filters={{type="animal", subtype="canine"}}},
}

newEntity{
	name = "dragon",
	type = "hostile", subtype = "dragon", cant_be_moved=true,
	display = 'D', color = colors.RED,
	level_range = {12, nil},
	sight = 3,
	rarity = 12,
	unit_power = 7,
	ai = "world_hostile", ai_state = {chase_distance=3},
	on_encounter = {type="ambush", width=10, height=10, nb={1,1}, filters={{type="dragon"}}},
}
