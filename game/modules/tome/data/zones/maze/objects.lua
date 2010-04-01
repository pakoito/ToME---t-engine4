-- ToME - Tales of Middle-Earth
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

load("/data/general/objects/objects.lua")

local Stats = require"engine.interface.ActorStats"

-- Artifact, droped (and used!) by the Minautaur
newEntity{ base = "BASE_HELM",
	define_as = "HELM_OF_HAMMERHAND",
	name = "Steel Helm of Hammerhand", unique=true,
	desc = [[A great helm as steady as the heroes of the Westdike. Mighty were the blows of Helm, the Hammerhand!]],
	require = { stat = { str=16 }, },
	cost = 20,

	wielder = {
		combat_armor = 3,
		fatigue = 8,
		inc_stats = { [Stats.STAT_STR] = 3, [Stats.STAT_CON] = 3, [Stats.STAT_WIL] = 4 },
		combat_physresist = 7,
		combat_mentalresist = 7,
		combat_spellresist = 7,
	},
}
