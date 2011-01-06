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

newTalent{
	name = "Knockback", short_name = "GOLEM_KNOCKBACK",
	type = {"golem/fighting", 1},
	require = techs_req1,
	points = 5,
	cooldown = 10,
	range = 10,
	stamina = 5,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.6) end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "Your golem can not do that currently.") return end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end

		if self.ai_target then self.ai_target.target = target end

		local l = line.new(self.x, self.y, x, y)
		local lx, ly = l()
		local tx, ty = self.x, self.y
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end

		self:move(tx, ty, true)

		-- Attack ?
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return true end
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		-- Try to knockback !
		if hit then
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 5 - self:getTalentLevel(t) / 2) and target:canBe("knockback") then
				target:knockback(self.x, self.y, 3)
			else
				game.logSeen(target, "%s resists the knockback!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Your golem rushes to the target, knocking it back and doing %d%% damage.
		Knockback chance will increase with talent level.]]):format(100 * damage)
	end,
}

newTalent{
	name = "Taunt", short_name = "GOLEM_TAUNT",
	type = {"golem/fighting", 2},
	require = techs_req2,
	points = 5,
	cooldown = function(self, t)
		return 20 - self:getTalentLevelRaw(t) * 2
	end,
	range = 10,
	stamina = 5,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end

		if self.ai_target then self.ai_target.target = target end
		target:setTarget(self)
		game.logSeen(self, "%s provokes %s to attack it.", self.name:capitalize(), target.name)
		return true
	end,
	info = function(self, t)
		return ([[Orders your golem to taunt a target, forcing it to attack the golem.]]):format()
	end,
}

newTalent{
	name = "Crush", short_name = "GOLEM_CRUSH",
	type = {"golem/fighting", 3},
	require = techs_req3,
	points = 5,
	cooldown = 10,
	range = 10,
	stamina = 5,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentWeaponDamage(t, 0.8, 1.6) end,
	getPinDuration = function(self, t) return 2 + self:getTalentLevel(t) end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "Your golem can not do that currently.") return end

		local tg = {type="hit", range=self:getTalentRange(t)}
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end

		if self.ai_target then self.ai_target.target = target end

		local l = line.new(self.x, self.y, x, y)
		local lx, ly = l()
		local tx, ty = self.x, self.y
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end

		self:move(tx, ty, true)

		-- Attack ?
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return true end
		local hit = self:attackTarget(target, nil, t.getDamage(self, t), true)

		-- Try to knockback !
		if hit then
			if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 10 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
				target:setEffect(target.EFF_PINNED, t.getPinDuration(self, t), {})
			else
				game.logSeen(target, "%s resists the crushing!", target.name:capitalize())
			end
		end

		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getPinDuration(self, t)
		return ([[Your golem rushes to the target, crushing it to the ground for %d turns and doing %d%% damage.
		Pinning chance will increase with talent level.]]):
		format(duration, 100 * damage)
	end,
}

newTalent{
	name = "Pound", short_name = "GOLEM_POUND",
	type = {"golem/fighting", 3},
	require = techs_req4,
	points = 5,
	cooldown = 15,
	range = 10,
	stamina = 5,
	requires_target = true,
	getGolemDamage = function(self, t)
		return self:combatTalentWeaponDamage(t, 0.4, 1.1)
	end,
	getDazeDuration = function(self, t) return 2 + self:getTalentLevel(t) end,
	action = function(self, t)
		if self:attr("never_move") then game.logPlayer(self, "Your golem can not do that currently.") return end

		local tg = {type="ball", radius=2, friendlyfire=false, range=self:getTalentRange(t)}
		local olds = game.target.source_actor
		game.target.source_actor = self
		local x, y, target = self:getTarget(tg)
		game.target.source_actor = olds
		if not x or not y or not target then return nil end
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > self:getTalentRange(t) then return nil end

		local l = line.new(self.x, self.y, x, y)
		local lx, ly = l()
		local tx, ty = self.x, self.y
		lx, ly = l()
		while lx and ly do
			if game.level.map:checkAllEntities(lx, ly, "block_move", self) then break end
			tx, ty = lx, ly
			lx, ly = l()
		end

		if self.ai_target then self.ai_target.target = target end

		-- Attack & daze
		self:project({type="ball", radius=2, friendlyfire=false}, tx, ty, function(xx, yy)
			if xx == self.x and yy == self.y then return end
			local target = game.level.map(xx, yy, Map.ACTOR)
			if target and self:attackTarget(target, nil, t.getGolemDamage(self, t), true) then
				if target:checkHit(self:combatAttackStr(), target:combatPhysicalResist(), 0, 95, 10 - self:getTalentLevel(t) / 2) and target:canBe("stun") then
					target:setEffect(target.EFF_DAZED, t.getDazeDuration(self, t), {})
				else
					game.logSeen(target, "%s resists the dazing blow!", target.name:capitalize())
				end
			end
		end)

		return true
	end,
	info = function(self, t)
		local duration = t.getDazeDuration(self, t)
		local damage = t.getGolemDamage(self, t)
		return ([[Your golem rushes to the target, pounding the area of radius 2, dazing all foes for %d turns and doing %d%% damage.
		Daze chance increases with talent level.]]):
		format(duration, 100 * damage)
	end,
}
