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

--load("/data/general/objects/egos/charged-attack.lua")

newEntity{
	name = "flaming ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.FIRE] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.64 end)},
	},
}
newEntity{
	name = "icy ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.ICE] = resolvers.mbonus_material(15, 4, function(e, v) return v * 0.7 end)},
	},
}
newEntity{
	name = "acidic ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.ACID] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.7 end)},
	},
}
newEntity{
	name = "shocking ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.7 end)},
	},
}
newEntity{
	name = "poisonous ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.POISON] = resolvers.mbonus_material(45, 6, function(e, v) return v * 0.5 end)},
	},
}

newEntity{
	name = "slime-covered ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.SLIME] = resolvers.mbonus_material(45, 6, function(e, v) return v * 0.9 end)},
	},
}

newEntity{
	name = " of accuracy", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat={atk = resolvers.mbonus_material(20, 2, function(e, v) return v * 0.3 end)},
}

newEntity{
	name = "phase ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 6,
	combat={apr = resolvers.mbonus_material(15, 1, function(e, v) return v * 0.3 end)},
}

newEntity{
	name = "elemental ", prefix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = true,
	rarity = 25,
	cost = 35,
	wielder = {
		melee_project={
			[DamageType.FIRE] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.7 end),
			[DamageType.ICE] = resolvers.mbonus_material(15, 4, function(e, v) return v * 0.7 end),
			[DamageType.ACID] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.7 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.7 end),
		},
	},
}

newEntity{
	name = " of massacre", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}

newEntity{
	name = " of torment", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	greater_ego = true,
	rarity = 16,
	cost = 22,
	combat = {
		special_on_hit = {desc="10% chance to torment the target", fct=function(combat, who, target)
			if not rng.percent(100) then return end
			local eff = rng.table{"stun", "blind", "pin", "teleport", "stone", "confusion", "silence", "knockback"}
			if not target:canBe(eff) then return end
			if not target:checkHit(who:combatAttack(combat), target:combatPhysicalResist(), 15) then return end
			if eff == "stun" then target:setEffect(target.EFF_STUNNED, 3, {})
			elseif eff == "blind" then target:setEffect(target.EFF_BLINDED, 3, {})
			elseif eff == "pin" then target:setEffect(target.EFF_PINNED, 3, {})
			elseif eff == "stone" then target:setEffect(target.EFF_STONED, 3, {})
			elseif eff == "confusion" then target:setEffect(target.EFF_CONFUSED, 3, {power=60})
			elseif eff == "silence" then target:setEffect(target.EFF_SILENCED, 3, {})
			elseif eff == "knockback" then target:knockback(who.x, who.y, 3)
			elseif eff == "teleport" then target:teleportRandom(target.x, target.y, 10)
			end
		end},
	},
}
