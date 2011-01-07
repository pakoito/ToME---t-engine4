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
	name = "Dampening Field",
	type = {"chronomancy/inertia", 1},
	require = chrono_req1,
	points = 5,
	paradox = 5,
	cooldown = 10,
	tactical = {
		DEFENSE = 10,
	},
	range = 10,
	action = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_DAMPENING_FIELD, 10, {power=self:combatTalentSpellDamage(t, 5, 40) * getParadoxModifier(self, pm)})
		return true
	end,
	info = function(self, t)
		return ([[Creates a field that dampens any disruption to your inertial state, providing %d%% physical damage, stun, knockback, and daze resistance.
		The field lasts 10 turns and the effect scales with the Magic stat.]]):
		format(self:combatTalentSpellDamage(t, 5, 40) * getParadoxModifier(self, pm))
	end,
}

newTalent{
	name = "Friction",
	type = {"chronomancy/inertia", 1},
	require = chrono_req2,
	points = 5,
	paradox = 5,
	cooldown = 10,
	range = 6,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(target.EFF_FRICTION, 10, {src=self, dam=self:combatTalentSpellDamage(t, 4, 90)})
			end
		end)
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		return ([[Amplifies the effect of friction on your target causing it to take %0.2f fire damage over three turns every time it moves.
		The damage will increase with Magic stat.]]):format(damDesc(self, DamageType.FIRE, self:combatTalentSpellDamage(t, 4, 90)))
	end,
}

newTalent{
	name = "Stop",
	type = {"chronomancy/inertia",1},
	require = chrono_req1,
	points = 5,
	cooldown = 10,
	paradox = 5,
	range = 6,
	direct_hit = true,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		x, y = checkBackfire(self, x, y)
		self:project(tg, x, y, function(tx, ty)
			local target = game.level.map(tx, ty, Map.ACTOR)
			if not target then return end
			local dur = 3 + self:getTalentLevel(t)
			local power = -1 / dur
			if target:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 15) then
				target:setEffect(target.EFF_STOP, dur, {power = power})
			end
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[***BROKEN DO NOT CAST*** Reduces the targets global speed by %d%%.  The target will slowly recover all of its speed over %d turns.
		The chance will increase with Magic stat.]]):format(100, 3 + self:getTalentLevel(t))
	end,
}

newTalent{
	name = "Momentum Theft",
	type = {"chronomancy/inertia", 4},
	require = chrono_req4,
	points = 5,
	mode = "sustained",
	sustain_mana = 170,
	cooldown = 15,
	tactical = {
		ATTACKAREA = 10,
	},
	range = 5,
	do_storm = function(self, t)
		if self:getMana() <= 0 then
			local old = self.energy.value
			self.energy.value = 100000
			self:useTalent(self.T_THUNDERSTORM)
			self.energy.value = old
			return
		end

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, 5, true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		for i = 1, math.floor(self:getTalentLevel(t)) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:project(tg, a.x, a.y, DamageType.LIGHTNING, rng.avg(1, self:spellCrit(self:combatTalentSpellDamage(t, 15, 80)), 3))
			game.level.map:particleEmitter(self.x, self.y, math.max(math.abs(a.x-self.x), math.abs(a.y-self.y)), "lightning", {tx=a.x-self.x, ty=a.y-self.y})
			game:playSoundNear(self, "talents/lightning")
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/thunderstorm")
		game.logSeen(self, "#0080FF#A furious lightning storm forms around %s!", self.name)
		return {
			drain = self:addTemporaryValue("mana_regen", -3 * self:getTalentLevelRaw(t)),
		}
	end,
	deactivate = function(self, t, p)
		game.logSeen(self, "#0080FF#The furious lightning storm around %s calms down and disappears.", self.name)
		self:removeTemporaryValue("mana_regen", p.drain)
		return true
	end,
	info = function(self, t)
		return ([[Conjures a furious, raging lightning storm with a radius of 5 that follows you as long as this spell is active.
		Each turn a random lightning bolt will hit up to %d of your foes for 1 to %0.2f damage.
		This powerful spell will continuously drain mana while active.
		The damage will increase with the Magic stat]]):format(self:getTalentLevel(t), self:combatTalentSpellDamage(t, 15, 80))
	end,
}
