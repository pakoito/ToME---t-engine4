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

local function getGemLevel(self)
		local gem_level = 0
		if not self:getInven("PSIONIC_FOCUS")[1] then return gem_level end
		local tk_item = self:getInven("PSIONIC_FOCUS")[1]
		if tk_item.type == "gem" then 
			gem_level = tk_item.material_level
		else
			gem_level = 0
		end
		return gem_level
end

newTalent{
	name = "Mindhook",
	type = {"psionic/augmented-mobility", 1},
	require = psi_wil_high1,
	cooldown = 40,
	psi = 20,
	points = 5,
	range = function(self, t)
		local r = 3+self:getTalentLevel(t)+self:getWil(4)
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		return math.floor(r*mult)
	end,
	--range = function(self, t) return 3+self:getTalentLevel(t)+self:getWil(4) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t)}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, engine.Map.ACTOR)
			if not target then return end
			local nx, ny = util.findFreeGrid(self.x, self.y, 5, true, {[Map.ACTOR]=true})
			if not nx then return end
			target:move(nx, ny, true)

		end)
		game:playSoundNear(self, "talents/arcane")

		return true
	end,
	info = function(self, t)
		return ([[Briefly extend your telekinetic reach to grab an enemy and haul them towards you.
		Works on enemies up to %d squares away.]]):
		format(3+self:getTalentLevel(t)+self:getWil(4))
	end,
}



newTalent{
	name = "Quick as Thought",
	type = {"psionic/augmented-mobility", 2},
	points = 5,
	random_ego = "utility",
	cooldown = 80,
	psi = 30,
	require = psi_wil_high2,
	action = function(self, t)
		self:setEffect(self.EFF_QUICKNESS, 10+self:getWil(10), {power=self:getTalentLevel(t) * 0.1})
		return true
	end,
	info = function(self, t)
		local inc = self:getTalentLevel(t)*0.1
		local percentinc = ((1/(1-inc))-1)*100
		return ([[You encase your legs in precise sheathes of force, increasing your movement speed by %d%% for %d turns.]]):
		format(percentinc, 10+self:getWil(10))
	end,
}


newTalent{
	name = "Superhuman Leap",
	type = {"psionic/augmented-mobility", 3},
	require = psi_wil_high3,
	cooldown = 15,
	psi = 10,
	points = 5,
	range = function(self, t)
		local r = 1 + self:getWil(4) + self:getTalentLevel(t)
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		return math.floor(r*mult)
	end,
	action = function(self, t)
		local tg = {default_target=self, type="ball", nolock=true, pass_terrain=false, nowarning=true, range=self:getTalentRange(t), radius=0, requires_knowledge=false}
		x, y = self:getTarget(tg)
		if not x or not y then return nil end
		-- Target code does not restrict the target coordinates to the range, it lets the project function do it
		-- but we cant ...
		local _ _, x, y = self:canProject(tg, x, y)
		if self:hasLOS(x, y) and not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") and not game.level.map:checkEntity(x, y, Map.ACTOR, "block_move") then
			--self:teleportRandom(x, y, 0)
			self:move(x, y, true)
		else
			game.logSeen(self, "You can't move there.")
			return nil
		end
		return true
	end,
	info = function(self, t)
		local range = self:getTalentRange(t)
		return ([[You perform a precision, telekinetically-enhanced leap, landing up to %d squares away.]]):
		format(range)
	end,
}

newTalent{
	name = "Shattering Charge",
	type = {"psionic/augmented-mobility", 4},
	require = psi_wil_high4,
	points = 5,
	random_ego = "attack",
	psi = 60,
	cooldown = 10,
	tactical = {
		ATTACK = 10,
	},
	range = function(self, t)
		local r = 2 + self:getTalentLevel(t) + self:getWil(4)
		local gem_level = getGemLevel(self)
		local mult = (1 + 0.02*gem_level*(self:getTalentLevel(self.T_REACH)))
		return math.floor(r*mult)
	end,
	--range = function(self, t) return 3+self:getTalentLevel(t)+self:getWil(4) end,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		if not self:hasEffect(self.EFF_KINSPIKE_SHIELD) then game.logSeen(self, "You must have a spiked kinetic shield active. Cancelling charge.") return end
		if self:getTalentLevelRaw(t) < 5 then
			local tg = {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			if self:hasLOS(x, y) and not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") and not game.level.map:checkEntity(x, y, Map.ACTOR, "block_move") then
				local dam = self:spellCrit(self:combatTalentMindDamage(t, 20, 600))
				self:project(tg, x, y, DamageType.BATTER, self:spellCrit(rng.avg(2*dam/3, dam, 3)))
				local _ _, x, y = self:canProject(tg, x, y)
				game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
				game:playSoundNear(self, "talents/lightning")
				self:move(x, y, true)
			else
				game.logSeen(self, "You can't move there.")
				return nil
			end
			return true
		else

			local tg = {type="beam", range=self:getTalentRange(t), nolock=true, talent=t, display={particle="bolt_earth", trail="earthtrail"}}
			local x, y = self:getTarget(tg)
			if not x or not y then return nil end
			local dam = self:spellCrit(self:combatTalentMindDamage(t, 20, 600))

			for i = 1, self:getTalentRange(t) do
				self:project(tg, x, y, DamageType.DIG, 1)
			end
			self:project(tg, x, y, DamageType.BATTER, self:spellCrit(rng.avg(2*dam/3, dam, 3)))
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, tg.radius, "flamebeam", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")
			local l = line.new(self.x, self.y, x, y)
			local lx, ly = l()
			local tx, ty = self.x, self.y
			lx, ly = l()
			while lx and ly do
				if game.level.map:checkEntity(lx, ly, engine.Map.TERRAIN, "block_move", self) then break end
				tx, ty = lx, ly
				lx, ly = l()
			end
			self:move(tx, ty, true)
			return true		
		end
	end,
	info = function(self, t)
		local dam = self:combatTalentMindDamage(t, 20, 600)
		return ([[You expend massive amounts of energy to launch yourself forward at incredible speed. All enemies in your path will be knocked flying and dealt between %d and %d damage. At high levels, you can batter through solid walls.
		You must have a spiked kinetic shield erected in order to use this ability.]]):
		format(2*dam/3, dam)
	end,
}
