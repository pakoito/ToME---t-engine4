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

newEntity{
	name = "solid ", prefix=true,
	level_range = {1, 50},
	rarity = 4,
	cost = 5,
	elec_proof = true,
}

--[[
*detection
*light
*teleportation
*trap destruction
*flame
*lightning
digging (very rare)
healing

]]

newEntity{
	name = " of detection", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 8,
	cost_per_charge = 1,

	use_power = { name = "detect the presence of creatures around you", power = 6, use = function(self, who)
		local rad = 15 + who:getMag(20)
		who:setEffect(who.EFF_SENSE, 2, {
			range = rad,
			actor = 1,
		})
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}

newEntity{
	name = " of illumination", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 8,
	cost_per_charge = 0.4,

	use_power = { name = "light the area", power = 3, use = function(self, who)
		who:project({type="ball", range=0, friendlyfire=true, radius=15}, who.x, who.y, engine.engine.DamageType.LITE, 1)
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}

newEntity{
	name = " of trap destruction", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 14,
	cost_per_charge = 1,

	use_power = { name = "try to disarm any known traps", power = 6, use = function(self, who)
		local tg = {type="beam", range=2 + who:getMag(2)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		who:project(tg, x, y, function(px, py)
			local trap = game.level.map(px, py, engine.Map.TRAP)
			if not trap then return end
			local inc = self.material_level * 5 + who:getMag(30)
			who:attr("can_disarm", 1)
			who:attr("disarm_bonus", inc)

			trap:disarm(px, py, who)

			who:attr("disarm_bonus", -inc)
			who:attr("can_disarm", -1)
		end)
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}

newEntity{
	name = " of teleportation", suffix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 10,
	cost_per_charge = 1,

	use_power = { name = "teleport randomly", power = 6, use = function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, 100)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}

newEntity{
	name = " of lightning", suffix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 10,
	cost_per_charge = 1,

	use_power = { name = "fire a beam of lightning", power = 6, use = function(self, who)
		local tg = {type="beam", range=6 + who:getMag(4)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = (40 + who:getMag(20)) * self.material_level
		who:project(tg, x, y, engine.DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local _ _, x, y = who:canProject(tg, x, y)
		game.level.map:particleEmitter(who.x, who.y, math.max(math.abs(x-who.x), math.abs(y-who.y)), "lightning", {tx=x-who.x, ty=y-who.y})
		game:playSoundNear(who, "talents/lightning")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}

newEntity{
	name = " of flames", suffix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 10,
	cost_per_charge = 1,

	use_power = { name = "fire a beam of fire", power = 6, use = function(self, who)
		local tg = {type="beam", range=6 + who:getMag(4)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = (35 + who:getMag(20)) * self.material_level
		who:project(tg, x, y, engine.DamageType.FIRE, dam, {type="flame"})
		game:playSoundNear(who, "talents/fire")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}

newEntity{
	name = " of conjuration", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 6,
	cost_per_charge = 0.5,

	use_power = { name = "fire a bolt of a random element", power = 6, use = function(self, who)
		local tg = {type="bolt", range=10 + who:getMag(10)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = (45 + who:getMag(25)) * self.material_level
		local elem = rng.table{
			{engine.DamageType.FIRE, "flame"},
			{engine.DamageType.COLD, "freeze"},
			{engine.DamageType.LIGHTNING, "lightning_explosion"},
			{engine.DamageType.ACID, "acid"},
			{engine.DamageType.NATURE, "slime"},
			{engine.DamageType.BLIGHT, "slime"},
		}
		who:project(tg, x, y, elem[1], rng.avg(dam / 2, dam, 3), {type=elem[2]})
		game:playSoundNear(who, "talents/fire")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}

newEntity{
	name = " of healing", suffix=true, instant_resolve=true,
	level_range = {25, 50},
	rarity = 10,
	cost_per_charge = 2,

	use_power = { name = "heal", power = 7, use = function(self, who)
		local tg = {default_target=who, type="hit", nowarning=true, range=6 + who:getMag(4), first_target="friend"}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = (80 + who:getMag(50)) * self.material_level
		who:project(tg, x, y, engine.DamageType.HEAL, dam)
		game:playSoundNear(who, "talents/heal")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return nil, true
	end}
}
