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

--[[
Torques
*psionic shield
*psychoportation
*clear mind
*mind wave
]]

newEntity{
	name = " of psychoportation", addon=true, instant_resolve=true,
	keywords = {psyport=true},
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
	name = " of kinetic psionic shield", addon=true, instant_resolve=true,
	keywords = {kinshield=true},
	level_range = {1, 50},
	rarity = 7,

	charm_power_def = {add=3, max=100, floor=true},
	resolvers.charm("setup a psionic shield, reducing all physical and acid damage by %d for 6 turns", 20, function(self, who)
		who:setEffect(who.EFF_PSIONIC_SHIELD, 6, {kind="kinetic", power=self:getCharmPower()})
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of thermal psionic shield", addon=true, instant_resolve=true,
	keywords = {thermshield=true},
	level_range = {1, 50},
	rarity = 7,

	charm_power_def = {add=3, max=100, floor=true},
	resolvers.charm("setup a psionic shield, reducing all fire and cold damage by %d for 6 turns", 20, function(self, who)
		who:setEffect(who.EFF_PSIONIC_SHIELD, 6, {kind="thermal", power=self:getCharmPower()})
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of charged psionic shield", addon=true, instant_resolve=true,
	keywords = {chargedshield=true},
	level_range = {10, 50},
	rarity = 8,

	charm_power_def = {add=3, max=100, floor=true},
	resolvers.charm("setup a psionic shield, reducing all lightning and blight damage by %d for 6 turns", 20, function(self, who)
		who:setEffect(who.EFF_PSIONIC_SHIELD, 6, {kind="charged", power=self:getCharmPower()})
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of clear mind", addon=true, instant_resolve=true,
	keywords = {clearmind=true},
	level_range = {15, 50},
	rarity = 12,

	charm_power_def = {add=1, max=5, floor=true},
	resolvers.charm("absorbs and nullifies at most %d detrimental mental status effects in the next 6 turns", 20, function(self, who)
		who:setEffect(who.EFF_CLEAR_MIND, 6, {power=self:getCharmPower()})
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}

newEntity{
	name = " of mindblast", addon=true, instant_resolve=true,
	keywords = {mindblast=true},
	level_range = {15, 50},
	rarity = 8,

	charm_power_def = {add=45, max=300, floor=true},
	resolvers.charm(function(self) return ("fire a blast of psionic energies in a beam (dam %d-%d)"):format(self:getCharmPower()/2, self:getCharmPower()) end, 6, function(self, who)
		local tg = {type="beam", range=6 + who:getWil(4)}
		local x, y = who:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:getCharmPower()
		who:project(tg, x, y, engine.DamageType.MIND, rng.avg(dam / 2, dam, 3), {type="mind"})
		game.logSeen(who, "%s uses %s!", who.name:capitalize(), self:getName{no_count=true})
		return {id=true, used=true}
	end),
}
