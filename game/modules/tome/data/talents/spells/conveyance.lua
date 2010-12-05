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
	name = "Phase Door",
	type = {"spell/conveyance",1},
	require = spells_req1,
	points = 5,
	random_ego = "utility",
	mana = 10,
	cooldown = 8,
	tactical = {
		ESCAPE = 4,
	},
	requires_target = function(self, t) return self:getTalentLevel(t) >= 4 end,
	getRange = function(self, t) return 10 + self:combatSpellpower(0.1) end,
	getRadius = function(self, t) return 7 - self:getTalentLevelRaw(t) end,
	action = function(self, t)
		local target = self
		if self:getTalentLevel(t) >= 4 then
			local tg = {default_target=self, type="hit", nowarning=true, range=10, first_target="friend"}
			local tx, ty = self:getTarget(tg)
			if tx then
				local _ _, tx, ty = self:canProject(tg, tx, ty)
				if tx then
					target = game.level.map(tx, ty, Map.ACTOR) or self
				end
			end
		end
		if target ~= self and target:canBe("teleport") then
			local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
			if not hit then
				game.logSeen(target, "The spell fizzles!")
				return true
			end
		end

		-- Annoy them!
		if target ~= self and target:reactionToward(self) < 0 then target:setTarget(self) end

		local x, y = self.x, self.y
		local rad = t.getRange(self, t)
		local radius = t.getRadius(self, t)
		if self:getTalentLevel(t) >= 5 then
			local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=rad, radius=radius, requires_knowledge=false}
			x, y = self:getTarget(tg)
			if not x then return nil end
			-- Target code doesnot restrict the target coordinates to the range, it lets the poject function do it
			-- but we cant ...
			local _ _, x, y = self:canProject(tg, x, y)
			rad = radius

			-- Check LOS
			if not self:hasLOS(x, y) and rng.percent(35) then
				game.logPlayer(self, "The spell fizzles!")
				return true
			end
		end

		game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
		target:teleportRandom(x, y, rad)
		game.level.map:particleEmitter(target.x, target.y, 1, "teleport")

		if target ~= self then
			target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
		end

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local radius = t.getRadius(self, t)
		local range = t.getRange(self, t)
		return ([[Teleports you randomly with a small range of up to %d grids.
		At level 4 it allows you to specify which creature to teleport.
		At level 5 it allows you to choose the target area (radius %d). If the target area is not in line of sight there is a chance the spell will fizzle.
		The range will increase with the Magic stat]]):format(range, radius)
	end,
}

newTalent{
	name = "Teleport",
	type = {"spell/conveyance",2},
	require = spells_req2,
	points = 5,
	random_ego = "utility",
	mana = 20,
	cooldown = 30,
	tactical = {
		ESCAPE = 8,
	},
	requires_target = function(self, t) return self:getTalentLevel(t) >= 4 end,
	getRange = function(self, t) return 100 + self:combatSpellpower(1) end,
	getRadius = function(self, t) return 20 - self:getTalentLevel(t) end,
	action = function(self, t)
		local target = self

		if self:getTalentLevel(t) >= 5 then
			local tg = {default_target=self, type="hit", nowarning=true, range=10, first_target="friend"}
			local tx, ty = self:getTarget(tg)
			if tx then
				local _ _, tx, ty = self:canProject(tg, tx, ty)
				if tx then
					target = game.level.map(tx, ty, Map.ACTOR) or self
				end
			end
		end

		if target ~= self and target:canBe("teleport") then
			local hit = self:checkHit(self:combatSpellpower(), target:combatSpellResist() + (target:attr("continuum_destabilization") or 0))
			if not hit then
				game.logSeen(target, "The spell fizzles!")
				return true
			end
		end

		-- Annoy them!
		if target ~= self and target:reactionToward(self) < 0 then target:setTarget(self) end

		local x, y = self.x, self.y
		if self:getTalentLevel(t) >= 4 then
			local tg = {type="ball", nolock=true, pass_terrain=true, nowarning=true, range=t.getRange(self, t), radius=t.getRadius(self, t), requires_knowledge=false}
			x, y = self:getTarget(tg)
			if not x then return nil end
			-- Target code doesnot restrict the target coordinates to the range, it lets the poject function do it
			-- but we cant ...
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
			target:teleportRandom(x, y, t.getRadius(self, t))
			game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
		else
			game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
			target:teleportRandom(x, y, t.getRange(self, t), 15)
			game.level.map:particleEmitter(target.x, target.y, 1, "teleport")
		end

		if target ~= self then
			target:setEffect(target.EFF_CONTINUUM_DESTABILIZATION, 100, {power=self:combatSpellpower(0.3)})
		end

		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		local radius = t.getRadius(self, t)
		return ([[Teleports you randomly with a large range (%d), with a minimum range of 15.
		At level 4 it allows you to choose the target area (radius %d).
		At level 5 it allows you to specify which creature to teleport.
		The range will increase with the Magic stat]]):format(range, radius)
	end,
}

newTalent{
	name = "Displacement Shield",
	type = {"spell/conveyance", 3},
	require = spells_req3,
	points = 5,
	mana = 80,
	cooldown = 100,
	tactical = {
		DEFENSE = 10,
	},
	range = 10,
	requires_target = true,
	getTransferChange = function(self, t) return 20 + self:getTalentLevel(t) * 5 end,
	getMaxAbsorb = function(self, t) return self:combatTalentSpellDamage(t, 20, 210) end,
	getDuration = function(self, t) return util.bound(10 + math.floor(self:getTalentLevel(t) * 3), 10, 25) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local tx, ty, target = self:getTarget(tg)
		if not tx or not ty or not target then return nil end

		self:setEffect(self.EFF_DISPLACEMENT_SHIELD, t.getDuration(self, t), {power=t.getMaxAbsorb(self, t), target=target, chance=t.getTransferChange(self, t)})
		game:playSoundNear(self, "talents/teleport")
		return true
	end,
	info = function(self, t)
		local chance = t.getTransferChange(self, t)
		local maxabsorb = t.getMaxAbsorb(self, t)
		local duration = t.getDuration(self, t)
		return ([[This intricate spell erects a space distortion around the caster that is linked to another one around a target.
		Any time the caster should take damage there is a %d%% chance that it will instead be warped by the shield and hit the designated target.
		Once the maximum damage (%d) is absorbed, the time runs out (%d turns), or the target dies, the shield will crumble.
		Max damage shield can absorb will increase with the Magic stat]]):
		format(chance, maxabsorb, duration)
	end,
}

newTalent{
	name = "Probability Travel",
	type = {"spell/conveyance",4},
	mode = "sustained",
	require = spells_req4,
	points = 5,
	cooldown = 40,
	sustain_mana = 200,
	tactical = {
		MOVEMENT = 20,
	},
	getRange = function(self, t) return math.floor(4 + self:combatSpellpower(0.06) * self:getTalentLevel(t)) end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/teleport")
		return {
			prob_travel = self:addTemporaryValue("prob_travel", t.getRange(self, t)),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("prob_travel", p.prob_travel)
		return true
	end,
	info = function(self, t)
		local range = t.getRange(self, t)
		return ([[When you hit a solid surface this spell tears down the laws of probability to make you instantly appear on the other side.
		Teleports up to %d grids.
		Range will improve with your Magic stat.]]):
		format(range)
	end,
}
