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


-- generic weapons
newEntity{
	name = "blessing of the blood drinker", level = 2, weighting = 3, item_type="weapon",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.life_leech_chance = math.ceil(10 * power)
		item.wielder.life_leech_value = 15
	end,
}
newEntity{
	name = "blessing of shrouds", level = 1, weighting = 3, item_type="weapon",
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.combat.talent_on_hit = item.combat.talent_on_hit or {}
		item.combat.talent_on_hit[Talents.T_CREEPING_DARKNESS] = {level=math.ceil(5 * power), chance=5}
	end,
}
newEntity{
	name = "blessing of reproach", level = 1, weighting = 3, item_type="weapon",
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.combat.talent_on_hit = item.combat.talent_on_hit or {}
		item.combat.talent_on_hit[Talents.T_REPROACH] = {level=math.ceil(5 * power), chance=5}
	end,
}
newEntity{
	name = "blessing of strikes", level = 1, weighting = 3, item_type="weapon",
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.combat.talent_on_hit = item.combat.talent_on_hit or {}
		item.combat.talent_on_hit[Talents.T_WILLFUL_STRIKE] = {level=math.ceil(5 * power), chance=5}
	end,
}
newEntity{
	name = "blessing of blasts", level = 2, weighting = 3, item_type="weapon",
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.combat.talent_on_hit = item.combat.talent_on_hit or {}
		item.combat.talent_on_hit[Talents.T_BLAST] = {level=math.ceil(5 * power), chance=5}
	end,
}
newEntity{
	name = "blessing of whispers", level = 2, weighting = 3, item_type="weapon",
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.combat.talent_on_hit = item.combat.talent_on_hit or {}
		item.combat.talent_on_hit[Talents.T_HATEFUL_WHISPER] = {level=math.ceil(5 * power), chance=5}
	end,
}
newEntity{
	name = "blessing of eternal rest", level = 2, weighting = 3, item_type="weapon", uses_special_on_hit = true,
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.curse_kill_chance = math.ceil(3 * power)
		item.combat.special_on_hit = {
			desc=("%0.2f%% chance to instantly kill a target weaker than yourself."):format(item.curse_kill_chance or 3),
			fct=function(item, who, target)
				if target ~= who and rng.percent(item.curse_kill_chance or 3) and target:canBe("instakill") and not target.dead and target.life < who.life then
					game.logSeen(target, "%s collapses in a lifeless heap!", target.name:capitalize())
					target:die(who)
				end
			end
		}
	end,
}
newEntity{
	name = "blessing of the elder", level = 2, weighting = 3, item_type="weapon", uses_special_on_hit = true,
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.curse_kill_chance = math.ceil(10 * power)
		item.combat.special_on_hit = {
			desc=("%0.2f%% chance to instantly kill a target that is at least 3 levels beneath yourself."):format(item.curse_kill_chance or 10),
			fct=function(item, who, target)
				if target ~= who and rng.percent(item.curse_kill_chance or 10) and target:canBe("instakill") and not target.dead and target.level <= who.level - 3 then
					game.logSeen(target, "%s collapses in a lifeless heap!", target.name:capitalize())
					target:die(who)
				end
			end
		}
	end,
}

-- Cursed weapons
newEntity{
	name = "blessing of hate", level = 1, weighting = 3, item_type="weapon", subclass="Cursed", uses_special_on_hit = true,
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.curse_hate_per_hit = math.ceil(2 * power) * 0.01
		item.combat.special_on_hit = {
			desc=("Adds %0.2f hate per strike."):format(item.curse_hate_per_hit or 0.02),
			fct=function(item, who, target)
				if target ~= who then
					who:incHate(item.curse_hate_per_hit or 0.02)
				end
			end
		}
	end,
}
newEntity{
	name = "fell aura", level = 1, weighting = 3, item_type="weapon", subclass="Cursed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_WIL] = (item.wielder.inc_stats[Stats.STAT_WIL] or 0) + math.ceil(4 * power)

		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.DARKNESS] = (item.wielder.inc_damage[DamageType.DARKNESS] or 0) + math.ceil(8 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.DARKNESS] = (item.wielder.resists_pen[DamageType.DARKNESS] or 0) + math.ceil(15 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/gloom"] = math.max(item.wielder.talents_types_mastery["cursed/gloom"] or 0, math.ceil(5 * power) * 0.01)
	end,
}
newEntity{
	name = "gloom bringer", level = 2, weighting = 3, item_type="weapon", subclass="Cursed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_WIL] = (item.wielder.inc_stats[Stats.STAT_WIL] or 0) + math.ceil(6 * power)

		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.DARKNESS] = (item.wielder.inc_damage[DamageType.DARKNESS] or 0) + math.ceil(10 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.DARKNESS] = (item.wielder.resists_pen[DamageType.DARKNESS] or 0) + math.ceil(20 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/gloom"] = math.max(item.wielder.talents_types_mastery["cursed/gloom"] or 0, math.ceil(15 * power) * 0.01)
	end,
}
newEntity{
	name = "corpse call", level = 1, weighting = 3, item_type="weapon", subclass="Cursed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.PHYSICAL] = (item.wielder.inc_damage[DamageType.PHYSICAL] or 0) + math.ceil(4 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.PHYSICAL] = (item.wielder.resists_pen[DamageType.PHYSICAL] or 0) + math.ceil(8 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/slaughter"] = math.max(item.wielder.talents_types_mastery["cursed/slaughter"] or 0, math.ceil(5 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_SLASH] = math.max(item.wielder.talent_cd_reduction[Talents.T_SLASH] or 0, math.ceil(2 * power))
		item.wielder.talent_cd_reduction[Talents.T_FRENZY] = math.max(item.wielder.talent_cd_reduction[Talents.T_FRENZY] or 0, math.ceil(3 * power))
	end,
}
newEntity{
	name = "blood drinker", level = 2, weighting = 3, item_type="weapon", subclass="Cursed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.PHYSICAL] = (item.wielder.inc_damage[DamageType.PHYSICAL] or 0) + math.ceil(5 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.PHYSICAL] = (item.wielder.resists_pen[DamageType.PHYSICAL] or 0) + math.ceil(10 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/slaughter"] = math.max(item.wielder.talents_types_mastery["cursed/slaughter"] or 0, math.ceil(15 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_SLASH] = math.max(item.wielder.talent_cd_reduction[Talents.T_SLASH] or 0, math.ceil(2 * power))
		item.wielder.talent_cd_reduction[Talents.T_FRENZY] = math.max(item.wielder.talent_cd_reduction[Talents.T_FRENZY] or 0, math.ceil(3 * power))
	end,
}
newEntity{
	name = "soul hunter", level = 1, weighting = 3, item_type="weapon", subclass="Cursed",
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.combat.atk = (item.combat.atk or 0) + math.ceil(8 * power)
		item.combat.apr = (item.combat.apr or 0) + math.ceil(8 * power)
		item.combat.combat_physcrit = (item.combat.combat_physcrit or 0) + math.ceil(5 * power)

		item.wielder = item.wielder or {}
		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/endless-hunt"] = math.max(item.wielder.talents_types_mastery["cursed/endless-hunt"] or 0, math.ceil(5 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_HARASS_PREY] = math.max(item.wielder.talent_cd_reduction[Talents.T_HARASS_PREY] or 0, 1)
	end,
}
newEntity{
	name = "grim task", level = 2, weighting = 3, item_type="weapon", subclass="Cursed",
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.combat.atk = (item.combat.atk or 0) + math.ceil(10 * power)
		item.combat.apr = (item.combat.apr or 0) + math.ceil(10 * power)
		item.combat.combat_physcrit = (item.combat.combat_physcrit or 0) + math.ceil(5 * power)

		item.wielder = item.wielder or {}
		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/endless-hunt"] = math.max(item.wielder.talents_types_mastery["cursed/endless-hunt"] or 0, math.ceil(15 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_HARASS_PREY] = math.max(item.wielder.talent_cd_reduction[Talents.T_HARASS_PREY] or 0, 1)
	end,
}
newEntity{
	name = "discord", level = 1, weighting = 3, item_type="weapon", subclass="Cursed",
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.combat.physspeed = (item.combat.physspeed or 1) - 0.1

		item.wielder = item.wielder or {}
		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/strife"] = math.max(item.wielder.talents_types_mastery["cursed/strife"] or 0, math.ceil(5 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_DOMINATE] = math.max(item.wielder.talent_cd_reduction[Talents.T_DOMINATE] or 0, math.ceil(2 * power))
		item.wielder.talent_cd_reduction[Talents.T_BLINDSIDE] = math.max(item.wielder.talent_cd_reduction[Talents.T_BLINDSIDE] or 0, math.ceil(2 * power))
	end,
}
newEntity{
	name = "havoc", level = 2, weighting = 3, item_type="weapon", subclass="Cursed",
	apply = function(item, who, power)
		item.combat = item.combat or {}
		item.combat.physspeed = (item.combat.physspeed or 1) - 0.1

		item.wielder = item.wielder or {}
		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/strife"] = math.max(item.wielder.talents_types_mastery["cursed/strife"] or 0, math.ceil(15 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_DOMINATE] = math.max(item.wielder.talent_cd_reduction[Talents.T_DOMINATE] or 0, math.ceil(2 * power))
		item.wielder.talent_cd_reduction[Talents.T_BLINDSIDE] = math.max(item.wielder.talent_cd_reduction[Talents.T_BLINDSIDE] or 0, math.ceil(2 * power))
	end,
}

-- Doomed weapons
newEntity{
	name = "blessing of force", level = 1, weighting = 3, item_type="weapon", item_subtype="staff", subclass="Doomed",
	apply = function(item, who, power)
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.PHYSICAL] = (item.wielder.inc_damage[DamageType.PHYSICAL] or 0) + math.ceil(8 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.PHYSICAL] = (item.wielder.resists_pen[DamageType.PHYSICAL] or 0) + math.ceil(15 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/force-of-will"] = math.max(item.wielder.talents_types_mastery["cursed/force-of-will"] or 0, math.ceil(5 * power) * 0.01)
	end,
}
newEntity{
	name = "blessing of concussion", level = 2, weighting = 3, item_type="weapon", item_subtype="staff", subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.PHYSICAL] = (item.wielder.inc_damage[DamageType.PHYSICAL] or 0) + math.ceil(10 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.PHYSICAL] = (item.wielder.resists_pen[DamageType.PHYSICAL] or 0) + math.ceil(20 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/force-of-will"] = math.max(item.wielder.talents_types_mastery["cursed/force-of-will"] or 0, math.ceil(15 * power) * 0.01)
	end,
}
newEntity{
	name = "dark blessing", level = 1, weighting = 3, item_type="weapon", item_subtype="staff", subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.DARKNESS] = (item.wielder.inc_damage[DamageType.DARKNESS] or 0) + math.ceil(8 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.DARKNESS] = (item.wielder.resists_pen[DamageType.DARKNESS] or 0) + math.ceil(15 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/darkness"] = math.max(item.wielder.talents_types_mastery["cursed/darkness"] or 0, math.ceil(5 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_CREEPING_DARKNESS] = math.max(item.wielder.talent_cd_reduction[Talents.T_CREEPING_DARKNESS] or 0, math.ceil(3 * power))
		item.wielder.talent_cd_reduction[Talents.T_DARK_TORRENT] = math.max(item.wielder.talent_cd_reduction[Talents.T_DARK_TORRENT] or 0, 1)
	end,
}
newEntity{
	name = "black blessing", level = 2, weighting = 3, item_type="weapon", item_subtype="staff", subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.DARKNESS] = (item.wielder.inc_damage[DamageType.DARKNESS] or 0) + math.ceil(10 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.DARKNESS] = (item.wielder.resists_pen[DamageType.DARKNESS] or 0) + math.ceil(20 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/darkness"] = math.max(item.wielder.talents_types_mastery["cursed/darkness"] or 0, math.ceil(15 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_CREEPING_DARKNESS] = math.max(item.wielder.talent_cd_reduction[Talents.T_CREEPING_DARKNESS] or 0, math.ceil(5 * power))
		item.wielder.talent_cd_reduction[Talents.T_DARK_TORRENT] = math.max(item.wielder.talent_cd_reduction[Talents.T_DARK_TORRENT] or 0, math.ceil(2 * power))
	end,
}
newEntity{
	name = "blessing of shadows", level = 1, weighting = 3, item_type="weapon", item_subtype="staff", subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_MAG] = (item.wielder.inc_stats[Stats.STAT_MAG] or 0) + math.ceil(6 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/shadows"] = math.max(item.wielder.talents_types_mastery["cursed/shadows"] or 0, math.ceil(5 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_FOCUS_SHADOWS] = math.max(item.wielder.talent_cd_reduction[Talents.T_FOCUS_SHADOWS] or 0, 1)
	end,
}
newEntity{
	name = "blessing of the stalker", level = 2, weighting = 3, item_type="weapon", item_subtype="staff", subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_MAG] = (item.wielder.inc_stats[Stats.STAT_MAG] or 0) + math.ceil(8 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/shadows"] = math.max(item.wielder.talents_types_mastery["cursed/shadows"] or 0, math.ceil(15 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_FOCUS_SHADOWS] = math.max(item.wielder.talent_cd_reduction[Talents.T_FOCUS_SHADOWS] or 0, math.ceil(2 * power))
	end,
}
newEntity{
	name = "blessing of torments", level = 1, weighting = 3, item_type="weapon", item_subtype="staff", subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.MIND] = (item.wielder.inc_damage[DamageType.MIND] or 0) + math.ceil(8 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.MIND] = (item.wielder.resists_pen[DamageType.MIND] or 0) + math.ceil(15 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/punishments"] = math.max(item.wielder.talents_types_mastery["cursed/punishments"] or 0, math.ceil(5 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_REPROACH] = math.max(item.wielder.talent_cd_reduction[Talents.T_REPROACH] or 0, 1)
		item.wielder.talent_cd_reduction[Talents.T_HATEFUL_WHISPER] = math.max(item.wielder.talent_cd_reduction[Talents.T_HATEFUL_WHISPER] or 0, math.ceil(2 * power))
	end,
}
newEntity{
	name = "blessing of horrors", level = 2, weighting = 3, item_type="weapon", item_subtype="staff", subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.MIND] = (item.wielder.inc_damage[DamageType.MIND] or 0) + (10 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.MIND] = (item.wielder.resists_pen[DamageType.MIND] or 0) + (20 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/punishments"] = math.max(item.wielder.talents_types_mastery["cursed/punishments"] or 0, math.ceil(15 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_REPROACH] = math.max(item.wielder.talent_cd_reduction[Talents.T_REPROACH] or 0, 1)
		item.wielder.talent_cd_reduction[Talents.T_HATEFUL_WHISPER] = math.max(item.wielder.talent_cd_reduction[Talents.T_HATEFUL_WHISPER] or 0, math.ceil(3 * power))
	end,
}
newEntity{
	name = "blessing of raw magic", level = 1, weighting = 3, item_type="weapon", item_subtype="staff", subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.ARCANE] = (item.wielder.inc_damage[DamageType.ARCANE] or 0) + (8 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.ARCANE] = (item.wielder.resists_pen[DamageType.ARCANE] or 0) + (15 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/primal-magic"] = math.max(item.wielder.talents_types_mastery["cursed/primal-magic"] or 0, math.ceil(5 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_ARCANE_BOLTS] = math.max(item.wielder.talent_cd_reduction[Talents.T_ARCANE_BOLTS] or 0, 1)
		item.wielder.talent_cd_reduction[Talents.T_VAPORIZE] = math.max(item.wielder.talent_cd_reduction[Talents.T_VAPORIZE] or 0, math.ceil(5 * power))
	end,
}
newEntity{
	name = "blessing of unyielding magic", level = 2, weighting = 3, item_type="weapon", item_subtype="staff", subclass="Doomed",
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_damage = item.wielder.inc_damage or {}
		item.wielder.inc_damage[DamageType.ARCANE] = (item.wielder.inc_damage[DamageType.ARCANE] or 0) + (10 * power)

		item.wielder.resists_pen = item.wielder.resists_pen or {}
		item.wielder.resists_pen[DamageType.ARCANE] = (item.wielder.resists_pen[DamageType.ARCANE] or 0) + (20 * power)

		item.wielder.talents_types_mastery = item.wielder.talents_types_mastery or {}
		item.wielder.talents_types_mastery["cursed/primal-magic"] = math.max(item.wielder.talents_types_mastery["cursed/primal-magic"] or 0, math.ceil(15 * power) * 0.01)

		item.wielder.talent_cd_reduction = item.wielder.talent_cd_reduction or {}
		item.wielder.talent_cd_reduction[Talents.T_ARCANE_BOLTS] = math.max(item.wielder.talent_cd_reduction[Talents.T_ARCANE_BOLTS] or 0, math.ceil(3 * power))
		item.wielder.talent_cd_reduction[Talents.T_VAPORIZE] = math.max(item.wielder.talent_cd_reduction[Talents.T_VAPORIZE] or 0, math.ceil(10 * power))
	end,
}