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

newEntity{
	name = "quick ", prefix=true,
	level_range = {1, 50},
	rarity = 15,
	cost = 5,
	resolvers.genericlast(function(e) 
		e.use_power.power = math.ceil(e.use_power.power * rng.float(0.6, 0.8))
		e.charm_power = math.ceil(e.charm_power * rng.float(0.4, 0.7))
	end),
}

newEntity{
	name = "supercharded ", prefix=true,
	level_range = {1, 50},
	rarity = 15,
	cost = 5,
	resolvers.genericlast(function(e) 
		e.use_power.power = math.ceil(e.use_power.power * rng.float(1.2, 1.5))
		e.charm_power = math.ceil(e.charm_power * rng.float(1.3, 1.5))
	end),
}

--[[
*detection
*light
*teleportation
*trap destruction
*flame
*lightning
digging (very rare)
*healing

]]

newEntity{
	name = " of detection", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 8,

	charm_power_def = {add=5, max=10, floor=true},
	resolvers.charm("detect the presence of creatures around you (rad %d)", 15, function(self, who)
		local rad = self:getCharmPower()
		who:setEffect(who.EFF_SENSE, 2, {
			range = rad,
			actor = 1,
		})
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of illumination", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 8,

	charm_power_def = {add=4, max=15, floor=true},
	resolvers.charm("light the area (rad %d)", 5, function(self, who)
		who:project({type="ball", range=0, selffire=true, radius=self:getCharmPower()}, who.x, who.y, engine.DamageType.LITE, 1)
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of trap destruction", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 14,

	charm_power_def = {add=resolvers.genericlast(function(e) return e.material_level * 8 end), max=100, floor=true},
	resolvers.charm("try to disarm any known traps in a line (disarm power %d)", 15, function(self, who)
		local tg = {type="beam", range=2 + who:getMag(2)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		who:project(tg, x, y, function(px, py)
			local trap = game.level.map(px, py, engine.Map.TRAP)
			if not trap then return end
			local inc = self:getCharmPower()
			who:attr("can_disarm", 1)
			who:attr("disarm_bonus", inc)

			trap:disarm(px, py, who)

			who:attr("disarm_bonus", -inc)
			who:attr("can_disarm", -1)
		end)
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of teleportation", suffix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 10,

	charm_power_def = {add=15, max=60, floor=true},
	resolvers.charm("teleport randomly (rad %d)", 30, function(self, who)
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		who:teleportRandom(who.x, who.y, self:getCharmPower())
		game.level.map:particleEmitter(who.x, who.y, 1, "teleport")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}


newEntity{
	name = " of lightning", suffix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 10,

	charm_power_def = {add=45, max=300, floor=true},
	resolvers.charm(function(self) return ("fire a beam of lightning (dam %d-%d)"):format(self:getCharmPower()/3, self:getCharmPower()) end, 6, function(self, who)
		local tg = {type="beam", range=6 + who:getMag(4)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:getCharmPower()
		who:project(tg, x, y, engine.DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local _ _, x, y = who:canProject(tg, x, y)
		game.level.map:particleEmitter(who.x, who.y, math.max(math.abs(x-who.x), math.abs(y-who.y)), "lightning", {tx=x-who.x, ty=y-who.y})
		game:playSoundNear(who, "talents/lightning")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of flames", suffix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 10,

	charm_power_def = {add=25, max=250, floor=true},
	resolvers.charm("fire a beam of flames (dam %d)", 6, function(self, who)
		local tg = {type="beam", range=6 + who:getMag(4)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:getCharmPower()
		who:project(tg, x, y, engine.DamageType.FIRE, dam, {type="flame"})
		game:playSoundNear(who, "talents/fire")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of conjuration", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 6,

	charm_power_def = {add=25, max=250, floor=true},
	resolvers.charm(function(self) return ("fire a bolt of a random element (dam %d-%d)"):format(self:getCharmPower()/2, self:getCharmPower()) end, 6, function(self, who)
		local tg = {type="bolt", range=10 + who:getMag(10)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:getCharmPower()
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
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of healing", suffix=true, instant_resolve=true,
	level_range = {25, 50},
	rarity = 20,

	charm_power_def = {add=50, max=250, floor=true},
	resolvers.charm("heals the target for %d", 35, function(self, who)
		local tg = {default_target=who, type="hit", nowarning=true, range=6 + who:getWil(4), first_target="friend"}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:getCharmPower()
		who:project(tg, x, y, engine.DamageType.HEAL, dam)
		game:playSoundNear(who, "talents/heal")
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}
