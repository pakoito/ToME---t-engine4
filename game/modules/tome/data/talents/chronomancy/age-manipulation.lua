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
	paradox = 5,
	cooldown = 4,
	tactical = { ATTACK = 2, DISABLE = 2 },
	range = 10,
	reflectable = true,
	requires_target = true,
	proj_speed = 3,
	direct_hit = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 20, 200)*getParadoxModifier(self, pm) end,
	getDamageStat = function(self, t) return 2 + math.ceil(t.getDamage(self, t) / 15) end,
	action = function(self, t)
		local tg = {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="temporal_bolt"}}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:projectile(tg, x, y, DamageType.CLOCK, self:spellCrit(t.getDamage(self, t)))
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local damagestat = t.getDamageStat(self, t)
		return ([[Project a bolt of temporal energy, dealing %0.2f temporal damage and reducing all of the target's stats by %d for 3 turns.
		The damage will scale with your Paradox and Magic stat.]]):format(damDesc(self, DamageType.TEMPORAL, damage), damagestat)
	end,
}

newTalent{
	name = "Body Reversion",
	type = {"chronomancy/age-manipulation", 2},
	require = chrono_req2,
	points = 5,
	paradox = 10,
	cooldown = 10,
	tactical = { HEAL = 2 },
	getHeal = function(self, t) return self:combatTalentSpellDamage(t, 40, 440)*getParadoxModifier(self, pm) end,
	getRemoveCount = function(self, t) return math.floor(self:getTalentLevel(t)) end,
	action = function(self, t)
		self:heal(self:spellCrit(t.getHeal(self, t)), self)
		local target = self
		
		local effs = {}
		-- Go through all spell effects
		for eff_id, p in pairs(target.tmp) do
			local e = target.tempeffect_def[eff_id]
			if e.type ~= "time" then
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
		return ([[You revert your body to a previous state, healing yourself for %0.2f life and removing %d status effects (both good and bad).
		The life healed will scale with your Paradox and Magic stat.]]):
		format(heal, count)
	end,
}

newTalent{
	name = "Temporal Fugue",
	type = {"chronomancy/age-manipulation", 3},
	require = chrono_req3,
	points = 5,
	paradox = 15,
	cooldown = 15,
	tactical = { ATTACKAREA = 2, DISABLE= 2 },
	range = 0,
	radius = function(self, t)
		return 4 + math.floor(self:getTalentLevelRaw (t)/2)
	end,
	requires_target = true,
	target = function(self, t)
		return {type="cone", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, talent=t}
	end,
	getConfuseDuration = function(self, t) return math.floor((self:getTalentLevel(t) + 2) * getParadoxModifier(self, pm)) end,
	getConfuseEfficency = function(self, t) return (50 + self:getTalentLevelRaw(t) * 10) * getParadoxModifier(self, pm) end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		print (check)
		self:project(tg, self.x, self.y, DamageType.CONFUSION, {
			dur = t.getConfuseDuration(self, t),
			dam = t.getConfuseEfficency(self, t)
		})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "temporal_breath", {radius=tg.radius, tx=x-self.x, ty=y-self.y})
		game:playSoundNear(self, "talents/tidalwave")
		return true
	end,
	info = function(self, t)
		local duration = t.getConfuseDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Reverts the minds of all creatures in a %d radius cone to an infantile state, in effect confusing them for %d turns.
		The duration and power of the confuse will scale with your Paradox.]]):
		format(radius, duration)
	end,
}

newTalent{
	name = "Ashes to Ashes",
	type = {"chronomancy/age-manipulation",4},
	require = chrono_req4,
	points = 5,
	paradox = 20,
	cooldown = 20,
	tactical = { ATTACKAREA = 2 },
	range = 0,
	radius = 3,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 8, 135)*getParadoxModifier(self, pm) end,
	getDuration = function(self, t) return 5 + math.ceil(self:getTalentLevel(t)) end,
	getRadius = function(self, t) return 3 + math.floor(self:getTalentLevel(t)/4)end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.WASTING, t.getDamage(self, t),
			tg.radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=176, color_bg=196, color_bb=222},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			tg.selffire
		)
		game:playSoundNear(self, "talents/cloud")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		local radius = t.getRadius(self, t)
		return ([[You surround yourself with a radius %d aura of time distortion for %d turns that deals %0.2f stacking temporal damage over 3 turns to all other creatures.
		The damage will scale with your Paradox and Magic stat]]):format(radius, duration, damDesc(self, DamageType.TEMPORAL, damage))
	end,
}
