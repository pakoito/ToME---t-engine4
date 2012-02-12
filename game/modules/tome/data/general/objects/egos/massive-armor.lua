-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	power_source = {nature=true},
	name = " of the dragon", suffix=true, instant_resolve=true,
	keywords = {dragon=true},
	keywords = {dragon=true},
	level_range = {20, 50},
	greater_ego = 1,
	rarity = 40,
	cost = 60,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material("resists"),
			[DamageType.LIGHTNING] = resolvers.mbonus_material("resists"),
			[DamageType.FIRE] = resolvers.mbonus_material("resists"),
			[DamageType.COLD] = resolvers.mbonus_material("resists"),
			[DamageType.PHYSICAL] = resolvers.mbonus_material("resists"),
	},
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material("inc_stats"),
			[Stats.STAT_STR] = resolvers.mbonus_material("inc_stats"),
		},
		stun_immune = resolvers.mbonus_material("immunity"),
		knockback_immune = resolvers.mbonus_material("immunity"),
		disarm_immune = resolvers.mbonus_material("immunity"),
		talent_cd_reduction={[Talents.T_RUSH]=5},
	},
}

newEntity{
	power_source = {technique=true},
	name = "impenetrable ", prefix=true, instant_resolve=true,
	keywords = {impenetrable=true},
	keywords = {['impen.']=true},
	level_range = {10, 50},
	rarity = 8,
	cost = 7,
	wielder = {
		combat_armor = resolvers.mbonus_material("combat_armor"),
	},
}
