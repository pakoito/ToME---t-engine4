-- ToME - Tales of Maj'Eyal
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


newTalent{
	name = "Skate",
	type = {"psionic/augmented-mobility", 1},
	require = psi_wil_req1,
	points = 5,
	mode = "sustained",
	cooldown = 0,
	sustain_psi = 10,
	no_energy = true,
	tactical = { BUFF = 2 },
	getSpeed = function(self, t) return self:combatTalentScale(t, 0.2, 0.5, 0.75) end,
	getKBVulnerable = function(self, t) return self:combatTalentLimit(t, 1, 0.2, 0.8) end,
	activate = function(self, t)
		return {
			speed = self:addTemporaryValue("movement_speed", t.getSpeed(self, t)),
			knockback = self:addTemporaryValue("knockback_immune", -t.getKBVulnerable(self, t))
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("movement_speed", p.speed)
		self:removeTemporaryValue("knockback_immune", p.knockback)
		return true
	end,
	info = function(self, t)
		return ([[You telekinetically float just off the ground.
		This allows you to slide around the battle quickly, increasing your movement speed by %d%%. 
		It also makes you more vulnerable to being pushed around (-%d%% knockback resistance).]]): 
		format(t.getSpeed(self, t)*100, t.getKBVulnerable(self, t)*100) 
	end,
}

newTalent{
	name = "Quick as Thought",
	type = {"psionic/augmented-mobility", 2},
	require = psi_wil_req2,
	points = 5,
	random_ego = "utility",
	cooldown = 20,
	psi = 30,
	no_energy = true,
	getDuration = function(self, t) return math.floor(self:combatLimit(self:combatMindpower(0.1), 10, 4, 0, 6, 6)) end, -- Limit < 10
	speed = function(self, t) return self:combatTalentScale(t, 0.6, 2.0, 0.75) end,
	getBoost = function(self, t)
		return self:combatScale(self:getTalentLevel(t)*self:combatStatTalentIntervalDamage(t, "combatMindpower", 1, 9), 15, 0, 49, 34)
	end,
	action = function(self, t)
		self:setEffect(self.EFF_QUICKNESS, t.getDuration(self, t), {power=t.speed(self, t)})
		self:setEffect(self.EFF_CONTROL, t.getDuration(self, t), {power=t.getBoost(self, t)})
		return true
	end,
	info = function(self, t)
		local inc = t.speed(self, t)
		local percentinc = 100 * inc
		local boost = t.getBoost(self, t)
		return ([[Encase your body in a sheath of thought-quick forces, allowing you to control your body's movements directly without the inefficiency of dealing with crude mechanisms like nerves and muscles.
		Increases Accuracy by %d, your critical strike chance by %0.1f%% and your attack speed by %d%% for %d turns.
		The duration improves with your Mindpower.]]):
		format(boost, 0.5*boost, percentinc, t.getDuration(self, t))
	end,
}


newTalent{
	name = "Telekinetic Leap",
	type = {"psionic/augmented-mobility", 3},
	require = psi_wil_req3,
	cooldown = 15,
	psi = 10,
	points = 5,
	tactical = { CLOSEIN = 2 },
	range = function(self, t)
		return self:combatTalentLimit(t, 10, 5, 9) -- Limit < 10
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
	require = psi_wil_req4,
	points = 5,
	random_ego = "attack",
	psi = 60,
	cooldown = 10,
	tactical = { CLOSEIN = 2, ATTACK = { PHYSICAL = 2 } },
	range = function(self, t)
		return self:combatTalentLimit(t, 10, 6, 9) --Limit base range to 10
	end,
	--range = function(self, t) return 3+self:getTalentLevel(t)+self:getWil(4) end,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		if self:getTalentLevelRaw(t) < 5 then
			local tg = {type="beam", range=self:getTalentRange(t), nolock=true, talent=t}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			if self:hasLOS(x, y) and not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
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
		return ([[You expend massive amounts of energy to launch yourself across %d squares at incredible speed. All enemies in your path will be knocked flying and dealt between %d and %d damage. 
		At talent level 5, you can batter through solid walls.]]):
		format(range, 2*dam/3, dam)
	end,
}