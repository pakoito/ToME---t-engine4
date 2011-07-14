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

local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"
local Talents = require "engine.interface.ActorTalents"

newEntity{ name = "ben str", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(4, 1) }, }, }, }
newEntity{ name = "ben dex", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(4, 1) }, }, }, }
newEntity{ name = "ben mag", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(4, 1) }, }, }, }
newEntity{ name = "ben wil", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus_material(4, 1) }, }, }, }
newEntity{ name = "ben cun", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus_material(4, 1) }, }, }, }
newEntity{ name = "ben con", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_CON] = resolvers.mbonus_material(4, 1) }, }, }, }

newEntity{ name = "ben mentalresist", weighting = 1, copy = { wielder = { combat_mentalresist = resolvers.mbonus_material(4, 2) }, }, }
newEntity{ name = "ben physresist", weighting = 1, copy = { wielder = { combat_physresist = resolvers.mbonus_material(4, 2) }, }, }
newEntity{ name = "ben spellresist", weighting = 1, copy = { wielder = { combat_spellresist = resolvers.mbonus_material(4, 2) }, }, }
newEntity{ name = "ben max hate", weighting = 2, copy = { wielder = { max_hate = 1 }, }, }
	