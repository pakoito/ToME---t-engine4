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

local Stats = require "engine.interface.ActorStats"
local Talents = require "engine.interface.ActorTalents"

load("/data/general/objects/staves.lua")

-- This file describes artifacts not bound to a special location or quest, but still special(they do not get randomly generated)

newEntity{ base = "BASE_STAFF", define_as = "TELOS_SPIRE",
	power_source = {arcane=true},
	unique = true,
	name = "Telos Spire of Power", image = "object/artifact/staff_lost_staff_archmage_tarelion.png",
	unided_name = "pulsing staff",
	flavor_name = "magestaff",
	level_range = {37, 50},
	color=colors.VIOLET,
	rarity = false,
	desc = [[Telos was an extremely powerful mage during the Age of Dusk, hated by his peers, feared by the common folk he was hunted for a long while. He finaly fell in his place of power, Telmur, butt his spirit still lingered on.]],
	cost = 400,
	material_level = 5,

	require = { stat = { mag=48 }, },
	modes = {"fire", "cold", "lightning", "arcane"},
	combat = {
		is_greater = true,
		dam = 30,
		apr = 4,
		dammod = {mag=1.5},
		damtype = DamageType.BLIGHT,
	},
	wielder = {
		inc_stats = { [Stats.STAT_CUN] = 8, [Stats.STAT_MAG] = 7 },
		max_mana = 100,
		max_vim = 50,
		combat_spellpower = 30,
		combat_spellcrit = 30,
		combat_mentalresist = 16,
		combat_spellresist = 16,
		combat_critical_power = 30,
		spellsurge_on_crit = 7,
		damage_resonance = 15,
		inc_damage = { [DamageType.ARCANE] = 30, [DamageType.BLIGHT] = 30, [DamageType.COLD] = 30, [DamageType.DARKNESS] = 30, [DamageType.ACID] = 30, [DamageType.LIGHT] = 30, },
		damage_affinity = { [DamageType.ARCANE] = 15, [DamageType.BLIGHT] = 15, [DamageType.COLD] = 15, [DamageType.DARKNESS] = 15, [DamageType.ACID] = 15, [DamageType.LIGHT] = 15, },
		confusion_immune = 0.4,
		vim_on_crit = 6,
	},
}
