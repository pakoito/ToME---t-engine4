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

load("/data/general/objects/objects-maj-eyal.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_STAFF",
	power_source = {arcane=true},
	slot = "OFFHAND", slot_forbid = false,
	twohanded = false, add_name=false,
	define_as = "TELOS_BOTTOM_HALF", rarity=false, image = "object/artifact/staff_broken_bottom_telos.png",
	unided_name = "broken staff",
	name = "Telos's Staff (Bottom Half)", unique=true,
	desc = [[The bottom part of Telos's broken staff.]],
	require = { stat = { mag=35 }, },
	encumberance = 2.5,
	cost = 500,
	combat = {
		dam = 10,
		max_acc = 80,
		critical_power = 1.1,
		dammod = {mag=0.2},
		damtype = DamageType.PHYSICAL,
	},
	wielder = {
		inc_stats = { [Stats.STAT_MAG] = 4, },
		max_mana = 50,
		combat_mentalresist = 8,
		learn_talent = {[Talents.T_SAVAGERY] = 5},
	},
}
