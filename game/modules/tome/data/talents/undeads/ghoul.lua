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
	name = "Ghoul",
	type = {"undead/ghoul", 1},
	mode = "passive",
	require = undeads_req1,
	points = 5,
	on_learn = function(self, t)
		self.inc_stats[self.STAT_STR] = self.inc_stats[self.STAT_STR] + 2
		self:onStatChange(self.STAT_STR, 2)
		self.inc_stats[self.STAT_CON] = self.inc_stats[self.STAT_CON] + 2
		self:onStatChange(self.STAT_CON, 2)
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_STR] = self.inc_stats[self.STAT_STR] - 2
		self:onStatChange(self.STAT_STR, -2)
		self.inc_stats[self.STAT_CON] = self.inc_stats[self.STAT_CON] - 2
		self:onStatChange(self.STAT_CON, -2)
	end,
	info = function(self, t)
		return ([[Improves your ghoulish body, increasing strength and constitution by %d.]]):format(2 * self:getTalentLevelRaw(t))
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
	direct_hit = true,
	range = function(self, t) return math.floor(5 + self:getTalentLevel(t) * 1.2) end,
	requires_target = true,
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
	requires_target = true,
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
		return ([[Gnaw your target doing %d%% damage, trying to stun it instead of damaging it. If your attack hits, the target is stunned for %d turns.]]):
		format(100 * (0.2 + self:getTalentLevel(t) / 12), 3 + math.ceil(self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Retch",
	type = {"undead/ghoul",4},
	require = undeads_req4,
	points = 5,
	cooldown = 25,
	tactical = {
		DEFEND = 10,
		ATTACK = 10,
	},
	range=1,
	action = function(self, t)
		local duration = self:getTalentLevel(t) / 2 + 4
		local radius = 3
		local dam = (2 + self:getCon(8)) * self:getTalentLevel(t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=radius}
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.RETCH, dam,
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=30, color_bg=180, color_bb=60},
			nil, self:spellFriendlyFire()
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		return ([[Vomit on the ground around you, healing any undead in the area and damaging others.
		Lasts %d turns and deals %d blight damage.]]):format(self:getTalentLevel(t) / 2 + 4, damDesc(self, DamageType.BLIGHT, (2 + self:getCon(8)) * self:getTalentLevel(t)))
	end,
}
