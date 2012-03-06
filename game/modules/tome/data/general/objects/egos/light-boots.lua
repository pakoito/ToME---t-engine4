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

load("/data/general/objects/egos/boots.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"


newEntity{
	power_source = {technique=true},
	name = "stealthy ", prefix=true, instant_resolve=true,
	keywords = {stealth=true},
	level_range = {20, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		inc_stealth = resolvers.mbonus_material(10, 5),
	},
}
