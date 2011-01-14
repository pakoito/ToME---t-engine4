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
	name = "Turn Back the Clock",
	type = {"chronomancy/age-manipulation", 1},
	require = chrono_req1,
	points = 5,
	paradox = 3,
	cooldown = 5, 
	tactical = {
		ATTACK = 10,
	},
	range = 10,
	reflectable = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200)*getParadoxModifier(self, pm) end,
	getDamageStat = function(self, t) return 5 + math.ceil(t.getDamage(self, t) / 20) end, 
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.CLOCK, self:spellCrit(t.getDamage(self, t)))
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local damagestat = t.getDamageStat(self, t)
		return ([[Fires a bolt of temporal energy, dealing %0.2f temporal damage and reducing all of the target's stats by %d for 3 turns.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.TEMPORAL, damage), damagestat)
	end,
}

newTalent{
	name = "Body Reversion",
	type = {"chronomancy/age-manipulation", 2},
	require = chrono_req2,
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
	name = "Temporal Fugue",
	type = {"chronomancy/age-manipulation", 3},
	require = chrono_req3,
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
	getRadius = function (self, t) return 2 + self:getTalentLevelRaw (t) end, 
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
	name = "Ashes to Ashes",
	type = {"chronomancy/age-manipulation",4},
	require = chrono_req4,
	points = 5,
	paradox = 10,
	cooldown = 8,
	tactical = {
		ATTACK = 10,
	},
	range = 6,
	direct_hit = true,
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 220)*getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = {type="beam", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, DamageType.WASTING, self:spellCrit(t.getDamage(self, t)))
		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(x-self.x), math.abs(y-self.y)), "mana_beam", {tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Fires a short range beam that causes targets to waste away, slowing and inflicting %0.2f temporal damage over three turns to everything in it's path.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.TEMPORAL, damage))
	end,
}