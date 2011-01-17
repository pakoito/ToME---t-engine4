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
	name = "Recharge",
	type = {"chronomancy/energy", 1},
	require = chrono_req_high1,
	points = 5,
	paradox = 5,
	cooldown = 10,
	tactical = {
		HEAL = 10,
	},
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 40, 220)*getParadoxModifier(self, pm) end,
	getRemoveCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	action = function(self, t)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		local target = self
		local effs = {}
		-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.status == "detrimental" or "beneficial" then
				effs[#effs+1] = {"effect", eff_id}
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			if eff[1] == "effect" then
				target:removeEffect(eff[2])
			end
		end
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		local heal = t.getHeal(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[You revert your body to a previous state, healing you for %0.2f and removing %d status effects (both good and bad).
		The life healed will increase with the Magic stat]]):
		format(heal, count)
	end,
}

newTalent{
	name = "Temporal Wake",
	type = {"chronomancy/energy", 2},
	require = chrono_req_high2,
	points = 5,
	random_ego = "attack",
	paradox = 5,
	cooldown = 10,
	tactical = {
		ATTACK = 10,
		MOVEMENT = 10,
	},
	range = 6,
	direct_hit = true,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200) end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		if self:hasLOS(x, y) and not game.level.map:checkEntity(x, y, Map.TERRAIN, "block_move") then
			local dam = self:spellCrit(t.getDamage(self, t))
			self:project(tg, x, y, DamageType.LIGHTNING, rng.avg(dam / 6, dam / 2, 3))
			self:project(tg, x, y, DamageType.TEMPORAL, dam/2)
			local _ _, x, y = self:canProject(tg, x, y)
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "temporal_lightning", {tx=x-self.x, ty=y-self.y})
			game:playSoundNear(self, "talents/lightning")
			local tx, ty = util.findFreeGrid(x, y, 5, true, {[Map.ACTOR]=true})
			if tx and ty then
				self:move(tx, ty, true)
			end
		else
			game.logSeen(self, "You can't move there.")
			return nil
		end
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[You transform yourself into a powerful bolt of temporal lightning and move between two points dealing %0.2f to %0.2f lightning damage and %0.2f temporal damage to everything in your path.
		The damage will increase with the Magic stat]]):
		format(damDesc(self, DamageType.LIGHTNING, damage / 6),
		damDesc(self, DamageType.LIGHTNING, damage / 2),
		damDesc(self, DamageType.TEMPORAL, damage / 2))
	end,
}

newTalent{
	name = "Energy Redirection",
	type = {"chronomancy/energy", 3},
	require = chrono_req_high3,
	points = 5,
	paradox = 5,
	cooldown = 15,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 1,
	requires_target = true,
	getConfuseDuration = function(self, t) return math.floor((self:getTalentLevel(t) + 2) * getParadoxModifier(self, pm)) end,
	getConfuseEfficency = function(self, t) return (50 + self:getTalentLevelRaw(t) * 10) * getParadoxModifier(self, pm) end,
	getRadius = function (self, t) return 3 + self:getTalentLevelRaw (t) end,
	action = function(self, t)
		local tg = {type="cone", range=0, radius=t.getRadius(self, t), friendlyfire=false, talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		print (check)
		self:project(tg, self.x, self.y, DamageType.CONFUSION, {
			dur = t.getConfuseDuration(self, t),
			dam = t.getConfuseEfficency(self, t)
		})
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local duration = t.getConfuseDuration(self, t)
		local radius = t.getRadius (self, t)
		return ([[Reverts the minds of all creatures in a %d radius cone to an infantile state, in effect confusing them for %d turns.
		]]):
		format(radius, duration)
	end,
}

newTalent{
	name = "Entropy",
	type = {"chronomancy/energy",4},
	require = chrono_req_high4,
	points = 5,
	paradox = 10,
	cooldown = 8,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 10,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 240)*getParadoxModifier(self, pm) end,
	getRadius = function (self, t) return 1 + math.floor(self:getTalentLevel(t)/5) end,
	action = function(self, t)
		local tg = {type="ball", range=self:getTalentRange(t), radius=t.getRadius(self, t), friendlyfire=self:spellFriendlyFire(), talent=t, display={particle="bolt_fire", trail="firetrail"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.WASTING, self:spellCrit(t.getDamage(self, t)))
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local radius = t.getRadius(self, t)
		return ([[Slows and inflicts %0.2f temporal damage over three turns on everything with in a radius of %d as targets waste away.
		The damage will increase with the Magic stat]]):format(damage, radius)
	end,
}