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

local Talents = require("engine.interface.ActorTalents")
local Stats = require "engine.interface.ActorStats"

load("/data/general/objects/egos/armor.lua")

newEntity{
	power_source = {technique=true},
	name = "impenetrable ", prefix=true, instant_resolve=true,
	keywords = {impenetrable=true},
	level_range = {10, 50},
	rarity = 8,
	cost = 7,
	wielder = {
		combat_armor = resolvers.mbonus_material(12, 3),
	},
}

newEntity{
	power_source = {arcane=true},
	name = "fearforged ", prefix=true, instant_resolve=true,
	keywords = {fearforged=true},
	level_range = {40, 50},
	greater_ego = 1,
	rarity = 30,
	cost = 80,
	wielder = {
		resists={
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5),
			[DamageType.LIGHT] = resolvers.mbonus_material(10, 10, function(e, v) return 0, -v end),
			[DamageType.DARKNESS] = resolvers.mbonus_material(10, 5),
		},
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 5),
		},
		combat_mentalresist = resolvers.mbonus_material(5, 5),
		combat_physresist = resolvers.mbonus_material(5, 5),
		combat_spellresist = resolvers.mbonus_material(5, 5),
		fatigue = resolvers.mbonus_material(10, 5),
	},	
}