-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

newTalentType{ type="misc/misc", name = "combat", description = "Combat techniques" }

newTalent{
	name = "Kick",
	type = {"misc/misc", 1},
	points = 1,
	cooldown = 6,
	power = 2,
	range = 1,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if core.fov.distance(self.x, self.y, x, y) > 1 then return nil end

		target:knockback(self.x, self.y, 2 + self:getDex())
		return true
	end,
	info = function(self, t)
		return "Kick!"
	end,
}

newTalent{
	name = "Acid Spray",
	type = {"misc/misc", 1},
	points = 1,
	cooldown = 6,
	power = 2,
	range = 6,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ACID, 1 + self:getDex(), {type="acid"})
		return true
	end,
	info = function(self, t)
		return "Zshhhhhhhhh!"
	end,
}

newTalent{
	name = "Manathrust",
	type = {"misc/misc", 1},
	points = 5,
	cooldown = 5,
	range = 20,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.ARCANE, rng.range(10, 20) * self:getTalentLevel(t))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "mana_beam", {tx=x-self.x, ty=y-self.y})
		return true
	end,
	info = function(self, t)
		return "Zzttt"
	end,
}

newTalent{
	name = "Flame",
	type = {"misc/misc",1},
	points = 5,
	cooldown = 5,
	range = 20,
	reflectable = true,
	proj_speed = 20,
	requires_target = true,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire", trail="firetrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE,rng.range(10, 20) * self:getTalentLevel(t))
		game.level.map:particleEmitter(self.x, self.y, tg.range, "flame", {tx=x-self.x, ty=y-self.y})
		return true
	end,
	info = function(self, t)
		return "burnnn"
	end,
}

newTalent{
	name = "Fireflash",
	type = {"misc/misc",3},
	points = 5,
	cooldown = 20,
	range = 15,
	proj_speed = 4,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=1 + self:getTalentLevelRaw(t), selffire=false, talent=t, display={particle="bolt_fire", trail="firetrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:projectile(tg, x, y, DamageType.FIRE, rng.range(4, 8) * self:getTalentLevel(t), function(self, tg, x, y, grids)
		game.level.map:particleEmitter(x, y, tg.radius, "fireflash", {radius=tg.radius, grids=grids, tx=x, ty=y})
		end)
		return true
	end,
	info = function(self, t)
		return "Zoooshh!"
	end,
}

newTalent{
	name = "Lightning",
	type = {"misc/misc", 1},
	points = 5,
	cooldown = 5,
	range = 20,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = rng.range(15, 30) * self:getTalentLevel(t)
		self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 3, dam, 3))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "lightning", {tx=x-self.x, ty=y-self.y})
		return true
	end,
	info = function(self, t)
		return "Zappp!"
	end,
}

newTalent{
	name = "Sunshield",
	type = {"misc/misc", 3},
	points = 5,
	cooldown = 100,
	range = 20,
	direct_hit = true,
	action = function(self, t)
		self:setEffect(self.EFF_SUNSHIELD, 30, {})
		return true
	end,
	info = function(self, t)
		return "ooooh"
	end,
}

newTalent{
	name = "Flameshock",
	type = {"misc/misc",2},
	points = 5,
	cooldown = 20,
	range = 0,
	radius = function(self, t)
		return 4 + self:getTalentLevelRaw(t)
	end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 120) end,
	getStunDuration = function(self, t) return self:getTalentLevelRaw(t) + 2 end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, DamageType.FIRE, rng.range(15, 30) * self:getTalentLevel(t))
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "breath_fire", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		return true
	end,
	info = function(self, t)
		return "swooosh"
	end,
}

