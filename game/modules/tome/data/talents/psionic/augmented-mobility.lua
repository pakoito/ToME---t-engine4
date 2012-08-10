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

newTalent{
	name = "Mindhook",
	type = {"psionic/augmented-mobility", 1},
	require = psi_cun_high1,
	cooldown = function(self, t)
		return math.ceil(20 - self:getTalentLevel(t)*2)
	end,
	psi = 20,
	points = 5,
	tactical = { CLOSEIN = 2 },
	range = function(self, t)
		local r = 2+self:getTalentLevelRaw(t)
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		r = math.floor(r*mult)
		return math.min(r, 10)
	end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		local target = game.level.map(x, y, engine.Map.ACTOR)
		if not target then
			game.logPlayer(self, "The target is out of range")
			return
		end
		target:pull(self.x, self.y, tg.range)
		target:setEffect(target.EFF_DAZED, 1, {})
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[Briefly extend your telekinetic reach to grab an enemy and haul them towards you.
		Works on enemies up to %d squares away. The cooldown decreases and the range increases with additional talent points spent.]]):
		format(range)
	end,
}



newTalent{
	name = "Quick as Thought",
	type = {"psionic/augmented-mobility", 2},
	points = 5,
	random_ego = "utility",
	cooldown = 80,
	psi = 30,
	no_energy = true,
	require = psi_cun_high2,
	getDuration = function(self, t)
		return 10 + self:combatMindpower(0.1)
	end,
	action = function(self, t)
		self:setEffect(self.EFF_QUICKNESS, t.getDuration(self, t), {power=self:getTalentLevel(t) * 0.2})
		return true
	end,
	info = function(self, t)
		local inc = self:getTalentLevel(t)*0.2
		local percentinc = 100 * inc
		--local percentinc = ((1/(1-inc))-1)*100
		return ([[You encase your legs in precise sheathes of force, increasing your movement speed by %d%% for %d turns.]]):
		format(percentinc, t.getDuration(self, t))
	end,
}


newTalent{
	--name = "Super"..self.race.." Leap",
	name = "Telekinetic Leap",
	type = {"psionic/augmented-mobility", 3},
	require = psi_cun_high3,
	cooldown = 15,
	psi = 10,
	points = 5,
	tactical = { CLOSEIN = 2 },
	range = function(self, t)
		local r = 2 + self:getTalentLevelRaw(t)
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		r = math.floor(r*mult)
		return math.min(r, 10)
	end,
	action = function(self, t)
		local tg = {default_target=self, type="ball", nolock=true, pass_terrain=false, nowarning=true, range=self:getTalentRange(t), radius=0, requires_knowledge=false}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, x, y = self:canProject(tg, x, y)
		if not x or not y then return nil end

		local fx, fy = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
		if not fx then
			return
		end
		self:move(fx, fy, true)

		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[You perform a precise, telekinetically-enhanced leap, landing up to %d squares away.]]):
		format(range)
	end,
}

newTalent{
	name = "Shattering Charge",
	type = {"psionic/augmented-mobility", 4},
	require = psi_cun_high4,
	points = 5,
	random_ego = "attack",
	psi = 60,
	cooldown = 10,
	tactical = { CLOSEIN = 2, ATTACK = { PHYSICAL = 1 } },
	range = function(self, t)
		local r = 2 + self:getTalentLevel(t)
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		r = math.floor(r*mult)
		return math.min(r, 10)
	end,
	--range = function(self, t) return 3+self:getTalentLevel(t)+self:getWil(4) end,
	direct_hit = true,
	requires_target = true,
	on_pre_use = function(self, t, silent)
		if not self:hasEffect(self.EFF_KINSPIKE_SHIELD) and not self:isTalentActive(self.T_KINETIC_SHIELD) then
			if not silent then game.logSeen(self, "You must either have a spiked kinetic shield or be able to spike one. Cancelling charge.") end
			return false
		end
		return true
	end,
	action = function(self, t)
		if self:getTalentLevelRaw(t) < 5 then
			local tg = {type="beam", range=self:getTalentRange(t), nolock=true, talent=t}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			if self:hasLOS(x, y) and not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
				if not self:hasEffect(self.EFF_KINSPIKE_SHIELD) and self:isTalentActive(self.T_KINETIC_SHIELD) then
					self:forceUseTalent(self.T_KINETIC_SHIELD, {ignore_energy=true})
				end
				local dam = self:mindCrit(self:combatTalentMindDamage(t, 20, 600))
				self:project(tg, x, y, DamageType.MINDKNOCKBACK, self:mindCrit(rng.avg(2*dam/3, dam, 3)))
				--local _ _, x, y = self:canProject(tg, x, y)
				game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
				game:playSoundNear(self, "talents/lightning")
				--self:move(x, y, true)
				local fx, fy = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
				if not fx then
					return
				end
				self:move(fx, fy, true)
			else
				game.logSeen(self, "You can't move there.")
				return nil
			end
			return true
		else

			local tg = {type="beam", range=self:getTalentRange(t), nolock=true, talent=t, display={particle="bolt_earth", trail="earthtrail"}}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			if not self:hasEffect(self.EFF_KINSPIKE_SHIELD) and self:isTalentActive(self.T_KINETIC_SHIELD) then
				self:forceUseTalent(self.T_KINETIC_SHIELD, {ignore_energy=true})
			end
			local dam = self:mindCrit(self:combatTalentMindDamage(t, 20, 600))

			for i = 1, self:getTalentRange(t) do
				self:project(tg, x, y, DamageType.DIG, 1)
			end
			self:project(tg, x, y, DamageType.MINDKNOCKBACK, self:mindCrit(rng.avg(2*dam/3, dam, 3)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")

			local block_actor = function(_, bx, by) return game.level.map:checkEntity(bx, by, engine.Map.TERRAIN, "block_move", self) end
			local l = self:lineFOV(x, y, block_actor)
			local lx, ly, is_corner_blocked = l:step()
			local tx, ty = self.x, self.y
			while lx and ly do
				if is_corner_blocked or block_actor(_, lx, ly) then break end
				tx, ty = lx, ly
				lx, ly, is_corner_blocked = l:step()
			end

			--self:move(tx, ty, true)
			local fx, fy = util.findFreeGrid(tx, ty, 5, true, {[Map.ACTOR]=true})
			if not fx then
				return
			end
			self:move(fx, fy, true)
			return true
		end
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		local dam = self:combatTalentMindDamage(t, 20, 600)
		return ([[You expend massive amounts of energy to launch yourself across %d squares at incredible speed. All enemies in your path will be knocked flying and dealt between %d and %d damage. At talent level five, you can batter through solid walls.
		You must have a spiked Kinetic Shield erected in order to not get smashed to a pulp when using this ability. Shattering charge automatically spikes your Kinetic Shield if available and not already spiked. If no such shield is available, you cannot use Shattering Charge.]]):
		format(range, 2*dam/3, dam)
	end,
}

