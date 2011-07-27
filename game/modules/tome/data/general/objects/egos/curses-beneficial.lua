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

newEntity{
	name="gift of strength", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_STR] = (item.wielder.inc_stats[Stats.STAT_STR] or 0) + math.ceil(6 * power)
	end,
}
newEntity{
	name="gift of dexterity", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_DEX] = (item.wielder.inc_stats[Stats.STAT_DEX] or 0) + math.ceil(6 * power)
	end,
}
newEntity{
	name="gift of magic", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_MAG] = (item.wielder.inc_stats[Stats.STAT_MAG] or 0) + math.ceil(6 * power)
	end,
}
newEntity{
	name="gift of will", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_WIL] = (item.wielder.inc_stats[Stats.STAT_WIL] or 0) + math.ceil(6 * power)
	end,
}
newEntity{
	name="gift of cunning", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_CUN] = (item.wielder.inc_stats[Stats.STAT_CUN] or 0) + math.ceil(6 * power)
	end,
}
newEntity{
	name="gift of constitution", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_CON] = (item.wielder.inc_stats[Stats.STAT_CON] or 0) + math.ceil(6 * power)
	end,
}

newEntity{
	name="gift of unyielding mind", level = 1, weighting = 2,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.combat_mentalresist = (item.wielder.combat_mentalresist or 0) + math.ceil(10 * power)
	end,
}
newEntity{
	name="gift of grim resolve", level = 1, weighting = 2,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.combat_physresist = (item.wielder.combat_physresist or 0) + math.ceil(10 * power)
	end,
}
newEntity{
	name="gift of mage bane", level = 1, weighting = 2,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.combat_spellresist = (item.wielder.combat_spellresist or 0) + math.ceil(10 * power)
	end,
}

newEntity{
	name="gift of dark passage", level = 1, weighting = 2,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.resists = item.wielder.resists or {}
		item.wielder.resists[DamageType.DARKNESS] = (item.wielder.resists[DamageType.DARKNESS] or 0) + math.ceil(25 * power)
	end,
}
newEntity{
	name="gift of arcane passage", level = 1, weighting = 2,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.resists = item.wielder.resists or {}
		item.wielder.resists[DamageType.DARKNESS] = (item.wielder.resists[DamageType.ARCANE] or 0) + math.ceil(25 * power)
	end,
}
newEntity{
	name="gift of strong mind", level = 1, weighting = 2,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.resists = item.wielder.resists or {}
		item.wielder.resists[DamageType.MIND] = (item.wielder.resists[DamageType.MIND] or 0) + math.ceil(25 * power)
	end,
}

newEntity{
	name="gift of endless hate", level = 2, weighting = 3,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.max_hate = (item.wielder.max_hate or 0) + math.ceil(12 * power) * 0.1
	end,
}
newEntity{
	name="gift of anger", level = 2, weighting = 3,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.hate_regen = (item.wielder.hate_regen or 0) + math.ceil(7 * power) * 0.001
	end,
}
newEntity{
	name="gift of seeking", level = 2, weighting = 3,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.combat_atk = (item.wielder.hate_regen or 0) + math.ceil(12 * power)
	end,
}
newEntity{
	name="gift of rending", level = 2, weighting = 3,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.combat_apr = (item.wielder.hate_regen or 0) + math.ceil(10 * power)
	end,
}
newEntity{
	name="gift of the dark", level = 2, weighting = 3,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[engine.DamageType.DARKNESS] = (item.wielder.inc_damage[engine.DamageType.DARKNESS] or 0) + math.ceil(10 * power)
	end,
}
newEntity{
	name="gift of dark mind", level = 2, weighting = 3,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[engine.DamageType.MIND] = (item.wielder.inc_damage[engine.DamageType.MIND] or 0) + math.ceil(10 * power)
	end,
}

newEntity{
	name="gift of the hungry", level = 1, weighting = 3, subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/dark-sustenance"] = math.max(item.wielder.talents_types_mastery["cursed/dark-sustenance"] or 0, math.ceil(8 * power) * 0.01)
	end,
}
newEntity{
	name="gift of the cursed", level = 1, weighting = 3, subclass="Cursed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/cursed-form"] = math.max(item.wielder.talents_types_mastery["cursed/cursed-form"] or 0, math.ceil(8 * power) * 0.01)
	end,
}
newEntity{
	name="gift of the cursed", level = 1, weighting = 3, subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/cursed-form"] = math.max(item.wielder.talents_types_mastery["cursed/cursed-form"] or 0, math.ceil(8 * power) * 0.01)
	end,
}
newEntity{
	name="gift of the outcast", level = 1, weighting = 2, subclass="Cursed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/dark-figure"] = math.max(item.wielder.talents_types_mastery["cursed/dark-figure"] or 0, math.ceil(8 * power) * 0.01)
	end,
}
newEntity{
	name="gift of the outcast", level = 1, weighting = 2, subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/dark-figure"] = math.max(item.wielder.talents_types_mastery["cursed/dark-figure"] or 0, math.ceil(8 * power) * 0.01)
	end,
}
