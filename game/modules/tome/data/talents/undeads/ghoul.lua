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

newTalent{
	name = "Ghoul",
	type = {"undead/ghoul", 1},
	mode = "passive",
	require = undeads_req1,
	points = 5,
	on_learn = function(self, t)
	end,
	on_unlearn = function(self, t)
	end,
	info = function(self, t)
		return ([[Improves your ghoulish body.]]):format()
	end,
}

newTalent{
	name = "Ghoulish Leap",
	type = {"undead/ghoul", 2},
	require = undeads_req2,
	points = 5,
	cooldown = 20,
	tactical = {
		ATTACK = 10,
	},
	range = function(self, t) return math.floor(5 + self:getTalentLevel(t) * 1.2) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end

		local l = line.new(self.x, self.y, x, y)
		local lx, ly = l()
		local tx, ty = lx, ly
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkEntity(lx, ly, Map.TERRAIN, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end

		-- Find space
		local fx, fy = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
		if not fx then
			return
		end
		self:move(fx, fy, true)

		return true
	end,
	info = function(self, t)
		return ([[Leap toward your target.]])
	end,
}

newTalent{
	name = "Gnaw",
	type = {"undead/ghoul", 3},
	require = undeads_req3,
	points = 5,
	cooldown = 15,
	tactical = {
		ATTACK = 20,
	},
	range = 1,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		local hitted = self:attackTarget(target, nil, 0.2 + self:getTalentLevel(t) / 12, true)

		if hitted then
			if target:checkHit(self:combatAttackDex(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, 3 + math.ceil(self:getTalentLevel(t)), {})
			else
				game.logSeen(target, "%s resists the stun!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		return ([[Gnaw your target doing %d%% damage, trying to stun it instead of damaging it. If your attack hits the target is stunned for %d turns.]]):
		format(100 * (0.2 + self:getTalentLevel(t) / 12), 3 + math.ceil(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Retch",
	type = {"undead/ghoul",4},
	require = undeads_req4,
	points = 5,
	tactical = {
		DEFEND = 10,
	},
	action = function(self, t)
		return true
	end,
	info = function(self, t)
		return ([[Vomit on the ground aruond you, healing any undeads in the area and damaging others.]])
	end,
}
