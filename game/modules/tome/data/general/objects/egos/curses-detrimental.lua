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

newEntity{ name="det str", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_STR] = resolvers.mbonus_material(4, 1, function(e, v) return 0, -v end), }, }, }, }
newEntity{ name="det dex", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_DEX] = resolvers.mbonus_material(4, 1, function(e, v) return 0, -v end) }, }, }, }
newEntity{ name="det mag", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_MAG] = resolvers.mbonus_material(4, 1, function(e, v) return 0, -v end) }, }, }, }
newEntity{ name="det wil", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_WIL] = resolvers.mbonus_material(4, 1, function(e, v) return 0, -v end) }, }, }, }
newEntity{ name="det cun", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_CUN] = resolvers.mbonus_material(4, 1, function(e, v) return 0, -v end) }, }, }, }
newEntity{ name="det con", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_CON] = resolvers.mbonus_material(4, 1, function(e, v) return 0, -v end) }, }, }, }
newEntity{ name="det lck", weighting = 1, copy = { wielder = { inc_stats = { [Stats.STAT_LCK] = resolvers.mbonus_material(4, 1, function(e, v) return 0, -v end) }, }, }, }

newEntity{ name="det res light", weighting = 2, copy = { wielder = { resists={ [DamageType.LIGHT] = -5 }, }, }, }
newEntity{ name="det res fire", weighting = 2, copy = { wielder = { resists={ [DamageType.FIRE] = -5 }, }, }, }
newEntity{ name="det res arcane", weighting = 2, copy = { wielder = { resists={ [DamageType.ARCANE] = -5 }, }, }, }

newEntity{ name="det mentalresist", weighting = 1, copy = { wielder = { combat_mentalresist = resolvers.mbonus_material(8, 3, function(e, v) return 0, -v end) }, }, }
newEntity{ name="det physresist", weighting = 1, copy = { wielder = { combat_physresist = resolvers.mbonus_material(8, 3, function(e, v) return 0, -v end) }, }, }
newEntity{ name="det spellresist", weighting = 1, copy = { wielder = { combat_spellresist = resolvers.mbonus_material(8, 3, function(e, v) return 0, -v end) }, }, }
newEntity{ name="det max air", weighting = 1, copy = { wielder = { max_air = -20 }, }, }

newEntity{
	name = "det fumble",
	weighting = 6,
	item_type="weapon",
	copy = {
		combat = {
			special_on_hit = {
				desc="4% chance of fumbling your weapon when striking.",
				fct=function(combat, who, target)
					if not rng.percent(4) then return end
					if not who:canBe("disarm") then return end
					who:setEffect(who.EFF_DISARMED, 3, {})
					game.logSeen(target, "%s fumbles the attack!", who.name:capitalize())
				end
			},
		},
	},
}
	
newEntity{
	name = "det knockback",
	weighting = 3,
	item_type="weapon",
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
	}
}
	
newEntity{
	name = "det teleport",
	weighting = 3,
	item_type="weapon",
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
	name = "det heal",
	weighting = 3,
	item_type="weapon",
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