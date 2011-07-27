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
	name="curse of weakness", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_STR] = (item.wielder.inc_stats[Stats.STAT_STR] or 0) - math.ceil(4 * power)
	end,
}
newEntity{
	name="curse of clumsiness", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_DEX] = (item.wielder.inc_stats[Stats.STAT_DEX] or 0) - math.ceil(4 * power)
	end,
}
newEntity{
	name="curse of the mundane", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_MAG] = (item.wielder.inc_stats[Stats.STAT_MAG] or 0) - math.ceil(4 * power)
	end,
}
newEntity{
	name="curse of the feeble", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_WIL] = (item.wielder.inc_stats[Stats.STAT_WIL] or 0) - math.ceil(4 * power)
	end,
}
newEntity{
	name="curse of the fool", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_CUN] = (item.wielder.inc_stats[Stats.STAT_CUN] or 0) - math.ceil(4 * power)
	end,
}
newEntity{
	name="curse of the sickly", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_CON] = (item.wielder.inc_stats[Stats.STAT_CON] or 0) - math.ceil(4 * power)
	end,
}
newEntity{
	name="curse of misfortune", level = 2, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.inc_stats = item.wielder.inc_stats or {}
		item.wielder.inc_stats[Stats.STAT_LCK] = (item.wielder.inc_stats[Stats.STAT_LCK] or 0) - math.ceil(4 * power)
	end,
}

newEntity{
	name="curse of harsh light", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.resists = item.wielder.resists or {}
		item.wielder.resists[DamageType.LIGHT] = (item.wielder.resists[DamageType.LIGHT] or 0) - math.ceil(10 * power)
	end,
}
newEntity{
	name="curse of fiery death", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.resists = item.wielder.resists or {}
		item.wielder.resists[DamageType.FIRE] = (item.wielder.resists[DamageType.FIRE] or 0) - math.ceil(10 * power)
	end,
}
newEntity{
	name="curse of frozen death", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.resists = item.wielder.resists or {}
		item.wielder.resists[DamageType.COLD] = (item.wielder.resists[DamageType.COLD] or 0) - math.ceil(10 * power)
	end,
}
newEntity{
	name="curse of madness", level = 2, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.resists = item.wielder.resists or {}
		item.wielder.resists[DamageType.MIND] = (item.wielder.resists[DamageType.MIND] or 0) - math.ceil(20 * power)
	end,
}

newEntity{
	name="curse of submission", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.combat_mentalresist = (item.wielder.combat_mentalresist or 0) - math.ceil(6 * power)
	end,
}
newEntity{
	name="curse of buckling", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.combat_physresist = (item.wielder.combat_physresist or 0) - math.ceil(6 * power)
	end,
}
newEntity{
	name="curse of the susceptibility", level = 1, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.combat_spellresist = (item.wielder.combat_spellresist or 0) - math.ceil(6 * power)
	end,
}

newEntity{
	name="curse of strangling", level = 1, weighting = 2,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.max_air = (item.wielder.max_air or 0) - math.ceil(20 * power)
	end,
}
newEntity{
	name="curse of burden", level = 2, weighting = 3,
	apply = function(item, who, power)
		item.encumber = item.encumber + 5
	end,
}
newEntity{
	name="curse of soothing", level = 2, weighting = 2,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.max_hate = (item.wielder.max_hate or 0) - math.ceil(1 * power)
	end,
}
newEntity{
	name="curse of dying", level = 2, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.life_regen = (item.wielder.life_regen or 0) - (math.ceil(100 * power) * 0.01 * 0.2)
	end,
}
newEntity{
	name="curse of misses", level = 2, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.combat_atk = (item.wielder.combat_atk or 0) - math.ceil(4 * power)
	end,
}
newEntity{
	name="curse of misses", level = 2, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.combat_atk = (item.wielder.combat_atk or 0) - math.ceil(4 * power)
	end,
}
newEntity{
	name="curse of elements", level = 2, weighting = 1,
	apply = function(item, who, power)
		item.wielder = item.wielder or {}
		item.wielder.resists = item.wielder.resists or {}
		item.wielder.resists[DamageType.FIRE] = (item.wielder.resists[DamageType.FIRE] or 0) - math.ceil(8 * power)
		item.wielder.resists[DamageType.COLD] = (item.wielder.resists[DamageType.COLD] or 0) - math.ceil(8 * power)
		item.wielder.resists[DamageType.LIGHTNING] = (item.wielder.resists[DamageType.LIGHTNING] or 0) - math.ceil(8 * power)
	end,
}

newEntity{
	name = "curse of rebuff", level = 2, weighting = 3, item_type="weapon",
	copy = {
		combat = {
			special_on_hit = {
				desc="4% chance of being knocked back when striking.",
				fct=function(combat, who, target)
					if not rng.percent(4) then return end
					if not who:canBe("knockback") then return end
					who:knockback(target.x, target.y, 3)
					game.logSeen(target, "%s flies back from the strike!", who.name:capitalize())
				end
			},
		},
	},
}
newEntity{
	name = "curse of dismissal", level = 2, weighting = 3, item_type="weapon",
	copy = {
		combat = {
			special_on_hit = {
				desc="4% chance of teleporting a short distance when striking.",
				fct=function(combat, who, target)
					if not rng.percent(4) then return end
					if not who:canBe("teleport") then return end
					who:teleportRandom(who.x, who.y, 10)
					game.logSeen(target, "%s strikes then suddenly disappears!", who.name:capitalize())
				end
			},
		},
	},
}
newEntity{
	name = "curse of kindness", level = 2, weighting = 3, item_type="weapon",
	copy = {
		combat = {
			special_on_hit = {
				desc="4% chance of healing the target by 50% of their maximum life.",
				fct=function(combat, who, target)
					if not rng.percent(4) then return end
					if target then
						local dam = math.min(target.max_life - target.life, target.max_life / 2)
						if dam > 0 then
							target:heal(dam)
							game.logSeen(target, "%s bestows %d life onto %s!", who.name:capitalize(), dam, target.name)
						end
					end
				end
			},
		},
	},
}