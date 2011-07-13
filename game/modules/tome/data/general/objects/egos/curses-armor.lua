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

newEntity{ name = "arm healing factor", weighting = 4, copy = { wielder = { healing_factor = resolvers.mbonus_material(30, 15) }, }, }
newEntity{ name = "arm max life", weighting = 2, copy = { wielder = { max_life = resolvers.mbonus_material(60, 40) }, }, }
newEntity{ name = "arm life regen", weighting = 2, copy = { wielder = { life_regen = resolvers.mbonus_material(15, 5, function(e, v) v=v/10 return 0, v end) }, }, }
newEntity{ name = "arm combat armor", weighting = 2, copy = { wielder = { combat_armor = resolvers.mbonus_material(8, 2), }, }, }

newEntity{ name = "arm res darkness", weighting = 3, copy = { wielder = { resists={ [DamageType.DARKNESS] = resolvers.mbonus_material(40, 20) }, }, }, }
newEntity{ name = "arm res light", weighting = 3, copy = { wielder = { resists={ [DamageType.LIGHT] = resolvers.mbonus_material(40, 20) }, }, }, }
newEntity{ name = "arm res mind", weighting = 2, copy = { wielder = { resists={ [DamageType.MIND] = resolvers.mbonus_material(25, 15) }, }, }, }
newEntity{ name = "arm res arcane", weighting = 2, copy = { wielder = { resists={ [DamageType.ARCANE] = resolvers.mbonus_material(25, 15) }, }, }, }

newEntity{ name = "arm hit darkness", weighting = 4, copy = { wielder = { on_melee_hit={ [DamageType.DARKNESS] = resolvers.mbonus_material(25, 5) } }, }, }
newEntity{ name = "arm hit mind", weighting = 2, copy = { wielder = { on_melee_hit={ [DamageType.MIND] = resolvers.mbonus_material(25, 5) } }, }, }
newEntity{name = "arm hit arcane",  weighting = 2, copy = { wielder = { on_melee_hit={ [DamageType.ARCANE] = resolvers.mbonus_material(25, 5) } }, }, }
