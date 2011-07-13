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


newEntity{ name = "wep proj darkness", weighting = 3, copy = { combat = { melee_project={[DamageType.DARKNESS] = resolvers.mbonus_material(45, 8)} }, }, }
newEntity{ name = "wep proj arcane", weighting = 1, copy = { combat = { melee_project={[DamageType.ARCANE] = resolvers.mbonus_material(45, 8)} }, }, }

newEntity{ name = "wep res physical", weighting = 1, copy = { wielder={ resists_pen = { [DamageType.PHYSICAL]= 25 }, }, }, }

newEntity{ name = "wep slaughter", weighting = 3, copy = { wielder = { talents_types_mastery = { ["cursed/slaughter"] = 0.2, }, }, }, }
newEntity{ name = "wep endless hunt", weighting = 3, copy = { wielder = { talents_types_mastery = { ["cursed/endless-hunt"] = 0.2, }, }, }, }
newEntity{ name = "wep strife", weighting = 3, copy = { wielder = { talents_types_mastery = { ["cursed/strife"] = 0.2, }, }, }, }

newEntity{ name = "wep life leech", weighting = 1, copy = { wielder = {
		life_leech_chance = resolvers.mbonus_material(8, 4),
		life_leech_value = 10,
	}, }, }	

newEntity{
	name = "wep hate per strike",
	weighting = 6,
	item_type="weapon",
	copy = {
		combat = {
			special_on_hit = {
				desc="Adds 0.03 hate per strike.",
				fct=function(combat, who, target)
					who:incHate(0.03)
				end
			},
		},
	},
}

newEntity{ name = "wep bleeding edge", weighting = 3, copy = { combat = { talent_on_hit = { [Talents.T_BLEEDING_EDGE] = {level=3, chance=5} }, }, }, }
newEntity{ name = "wep creeping darkness", weighting = 3, copy = { combat = { talent_on_hit = { [Talents.T_CREEPING_DARKNESS] = {level=3, chance=5} }, }, }, }