-- ToME - Tales of Middle-Earth
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

newTalentType{ type="grue/grue", name = "grue", description = "Gruesome!" }

newTalent{
	name = "Shadow Ball",
	type = {"grue/grue", 1},
	points = 1,
	shadow = 2,
	range = function(self, t)
		local k = self.kills + self.lurkkills
		if k <= 9 then return 1
		elseif k <= 24 then return 2
		elseif k <= 49 then return 3
		elseif k <= 99 then return 4
		else return 5
		end
	end,
	message = "You unleash a mighty ball of shadow.",
	action = function(self, t)
		local tg = {type="ball", radius=self:getTalentRange(t)}
		self:project(tg, self.x, self.y, DamageType.DARKNESS, 1)
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_shadow", {radius=tg.radius})
		return true
	end,
	info = function(self, t)
		return "Unleash a ball of darkness to extinguish adventurer's lites.\nThe more your eat the bigger the radius."
	end,
}

newTalent{
	name = "Dark Eyes",
	type = {"grue/grue", 1},
	points = 1,
	shadow = 1,
	range = function(self, t) return 2 end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t)}
		self:project(tg, x, y, DamageType.DARKNESS, 1)
		return true
	end,
	info = function(self, t)
		return "Unleash a ball of darkness to extinguish adventurer's lites."
	end,
}

newTalent{
	name = "Shadow Walk",
	type = {"grue/grue", 1},
	points = 1,
	range = function(self, t) return 2 end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t)}
		self:project(tg, x, y, DamageType.DARKNESS, 1)
		return true
	end,
	info = function(self, t)
		return "Unleash a ball of darkness to extinguish adventurer's lites."
	end,
}
