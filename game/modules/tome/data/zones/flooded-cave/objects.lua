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

local Talents = require "engine.interface.ActorTalents"
local Stats = require "engine.interface.ActorStats"
local DamageType = require "engine.DamageType"

load("/data/general/objects/2htridents.lua", function(e) e.rarity = e.trident_rarity end)
load("/data/general/objects/objects.lua")

-- Artifact, droped (and used!) by Bill the Stone Troll

newEntity{ base = "BASE_TRIDENT",
	define_as = "TRIDENT_TIDES",
	name = "Trident of the Tides", unique=true,
	desc = [[As you wield this trident you can feel the power of the tides rushing through your arms.
Tridents require the exotic weapons mastery talent to correctly use.]],
	require = { stat = { str=35 }, },
	cost = 300,
	material_level = 4,
	combat = {
		dam = 50,
		atk = 10,
		apr = 4,
		physcrit = 15,
		dammod = {str=1.3},
		damrange = 1.4,
	},

	wielder = {
		combat_spellresist = 18,
		see_invisible = 2,
		resists={[DamageType.COLD] = 25},
		inc_damage = { [DamageType.COLD] = 20 },
		melee_project={
			[DamageType.COLD] = 15,
			[DamageType.NATURE] = 20,
		},
	},

	max_power = 150, power_regen = 1,
	use_talent = { id = Talents.T_WATER_BOLT, level=3, power = 60 },
}
