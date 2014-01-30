-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	name = "Telos Spire of Power", image = "object/artifact/telos_spire_of_power.png",
	unided_name = "pulsing staff",
	flavor_name = "magestaff",
	level_range = {37, 50},
	color=colors.VIOLET,
	rarity = false,
	desc = [[Telos was an extremely powerful mage during the Age of Dusk, hated by his peers, feared by the common folk he was hunted for a long while. He finally fell in his place of power, Telmur, but his spirit still lingered on.]],
	cost = 400,
	material_level = 5,
	plot = true,

	require = { stat = { mag=48 }, },
	modes = {"fire", "cold", "lightning", "arcane"},
	combat = {
		sentient = "telos_full",
		is_greater = true,
		dam = 37,
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
		inc_damage = { [DamageType.ARCANE] = 37, [DamageType.BLIGHT] = 37, [DamageType.COLD] = 37, [DamageType.DARKNESS] = 37, [DamageType.ACID] = 37, [DamageType.LIGHT] = 37, },
		damage_affinity = { [DamageType.ARCANE] = 15, [DamageType.BLIGHT] = 15, [DamageType.COLD] = 15, [DamageType.DARKNESS] = 15, [DamageType.ACID] = 15, [DamageType.LIGHT] = 15, },
		confusion_immune = 0.4,
		vim_on_crit = 6,
	},
	max_power = 30, power_regen = 1,
	use_power = { name = "turn into a corrupted losgoroth (poison, disease, cut and confusion immune; converts half damage into life drain; does not require breath", power = 30,
		use = function(self, who)
			game.logSeen(who, "%s brandishes %s, turning into a corrupted losgoroth!", who.name:capitalize(), self:getName())
			who:setEffect(who.EFF_CORRUPT_LOSGOROTH_FORM, 8, {})
			return {id=true, used=true}
		end
	},
}
