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


newEntity{ name = "sta dam darkness", weighting = 4, copy = { wielder={ inc_damage = { [DamageType.DARKNESS] = resolvers.mbonus_material(20, 5), } }, }, }
newEntity{ name = "sta dam mind", weighting = 3, copy = { wielder={ inc_damage = { [DamageType.MIND] = resolvers.mbonus_material(20, 5), } }, }, }
newEntity{ name = "sta dam arcane", weighting = 2, copy = { wielder={ inc_damage = { [DamageType.ARCANE] = resolvers.mbonus_material(15, 4), } }, }, }
newEntity{ name = "sta dam physical", weighting = 2, copy = { wielder={ inc_damage = { [DamageType.PHYSICAL] = resolvers.mbonus_material(15, 4), } }, }, }

newEntity{ name = "sta pen darkness", weighting = 2, copy = { wielder={ resists_pen = { [DamageType.DARKNESS]= 40 }, } }, }
newEntity{ name = "sta pen mind", weighting = 2, copy = { wielder={ resists_pen = { [DamageType.MIND]= 40 }, } }, }
newEntity{ name = "sta pen arcane", weighting = 2, copy = { wielder={ resists_pen = { [DamageType.ARCANE]= 40 }, } }, }
newEntity{ name = "sta pen physical", weighting = 2, copy = { wielder={ resists_pen = { [DamageType.PHYSICAL]= 40 }, } }, }

newEntity{ name = "sta darkness", weighting = 2, copy = { wielder = { talents_types_mastery = { ["cursed/darkness"] = 0.2, } }, }, }
newEntity{ name = "sta force of will", weighting = 2, copy = { wielder = { talents_types_mastery = { ["cursed/force-of-will"] = 0.2, } }, }, }
newEntity{ name = "sta punishments", weighting = 2, copy = { wielder = { talents_types_mastery = { ["cursed/punishments"] = 0.2, } }, }, }
newEntity{ name = "sta shadows", weighting = 2, copy = { wielder = { talents_types_mastery = { ["cursed/shadows"] = 0.2, } }, }, }
newEntity{ name = "sta primal magic", weighting = 2, copy = { wielder = { talents_types_mastery = { ["cursed/primal-magic"] = 0.2, } }, }, }