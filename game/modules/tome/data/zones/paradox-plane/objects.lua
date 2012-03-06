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

load("/data/general/objects/objects.lua")

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

newEntity{ base = "BASE_LONGBOW",
	power_source = {arcane=true},
	define_as = "EPOCH_CURVE",
	-- not sure what rarity does so commented out for now
	rarity=false,
	name = "Epoch's Curve", unided_name = "white ash longbow", unique=true, image="object/artifact/bow_epochs_curve.png",
	desc = [[Epoch's Curve has served the Wardens for generations and was passed from Warden to Warden for many generations before being lost.
According to legend it was made from the first ash sapling to sprout after the Spellblaze and carries powers of both time and renewal.]],
	level_range = {20, 40},
	rarity = 200,
	require = { stat = { dex=24 }, },
	cost = 200,
	material_level = 5,
	combat = {
		range = 9,
		physspeed = 0.6,
	},
	wielder = {
		life_regen = 2.0,
		stamina_regen = 1.0,
		inc_damage={ [DamageType.TEMPORAL] = 10, },
		inc_stats = { [Stats.STAT_DEX] = 5, [Stats.STAT_WIL] = 4,  },
		ranged_project={[DamageType.TEMPORAL] = 15},
	},
}
