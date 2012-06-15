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

newEntity{
	define_as = "BASE_WHIP",
	slot = "MAINHAND", offslot = "OFFHAND",
	type = "weapon", subtype="whip",
	add_name = " (#COMBAT#)",
	display = "|", color=colors.SLATE, image = resolvers.image_material("whip", "leather"),
	moddable_tile = resolvers.moddable_tile("whip"),
	encumber = 3,
	rarity = 5,
	metallic = true,
	combat = { talented = "whip", damrange = 1.1, sound = "actions/melee", sound_miss = "actions/melee_miss",},
	desc = [[Sharp, long and deadly.]],
	randart_able = "/data/general/objects/random-artifacts/generic.lua",
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = { prefix=resolvers.mbonus(40, 5), suffix=resolvers.mbonus(40, 5) },
}
