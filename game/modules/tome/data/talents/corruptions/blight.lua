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
	name = "Dark Ritual",
	type = {"corruption/blight", 1},
	mode = "sustained",
	require = corrs_req1,
	points = 5,
	tactical = { ATTACK = 2 },
	sustain_vim = 20,
	cooldown = 30,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		local ret = {
			per = self:addTemporaryValue("combat_critical_power", self:combatTalentSpellDamage(t, 20, 60)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_critical_power", p.per)
		return true
	end,
	info = function(self, t)
		return ([[Increases your spell critical damage multiplier by %d%%.
		The multiplier will increase with your Magic stat.]]):
		format(self:combatTalentSpellDamage(t, 20, 60))
	end,
}

newTalent{
	name = "Corrupted Negation",
	type = {"corruption/blight", 2},
	require = corrs_req2,
	points = 5,
	cooldown = 10,
	vim = 30,
	range = 10,
	radius = 3,
	tactical = { ATTACKAREA = {BLIGHT = 1}, DISABLE = 2 },
	requires_target = true,
	target = function(self, t)
		return {type="ball", radius=self:getTalentRadius(t), range=self:getTalentRange(t), talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 28, 120))
		local nb = self:getTalentLevelRaw(t)
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end

			DamageType:get(DamageType.BLIGHT).projector(self, px, py, DamageType.BLIGHT, dam)

			local effs = {}

			-- Go through all spell effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" or e.type == "physical" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained spells
			for tid, act in pairs(target.sustain_talents) do
				if act then
					effs[#effs+1] = {"talent", tid}
				end
			end

			for i = 1, nb do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if self:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 5) then
					target:crossTierEffect(target.EFF_SPELLSHOCKED, self:combatSpellpower())
					if eff[1] == "effect" then
						target:removeEffect(eff[2])
					else
						target:forceUseTalent(eff[2], {ignore_energy=true})
					end
				end
			end
		end, nil, {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Project a corrupted blast of power that deals %0.2f blight damage and removes %d magical or physical effects from any creatures caught in the radius 3 ball.
		The damage will increase with Magic stat.]]):format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 28, 120)), self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Corrosive Worm",
	type = {"corruption/blight", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 10,
	vim = 12,
	range = 10,
	tactical = { ATTACK = {ACID = 2} },
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CORROSIVE_WORM, 10, {src=self, dam=self:spellCrit(self:combatTalentSpellDamage(t, 10, 60)), explosion=self:spellCrit(self:combatTalentSpellDamage(t, 10, 230))})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Infect your target with a corrosive worm that deals %0.2f acid damage per turn for 10 turns.
		If the target dies while the worm is inside it will explode, doing %0.2f acid damage in a radius of 4.
		The damage will increase with Magic stat.]]):
		format(damDesc(self, DamageType.ACID, self:combatTalentSpellDamage(t, 10, 60)), damDesc(self, DamageType.ACID, self:combatTalentSpellDamage(t, 10, 230)))
	end,
}

newTalent{
	name = "Poison Storm",
	type = {"corruption/blight", 4},
	require = corrs_req4,
	points = 5,
	vim = 36,
	cooldown = 30,
	range = 0,
	radius = 4,
	tactical = { ATTACKAREA = {NATURE = 2} },
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	action = function(self, t)
		local duration = 5 + self:getTalentLevel(t)
		local radius = self:getTalentRadius(t)
		local dam = self:spellCrit(self:combatTalentSpellDamage(t, 12, 130))
		local actor = self
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			self.x, self.y, duration,
			DamageType.POISON, {dam=dam, apply_power=actor:combatSpellpower()},
			radius,
			5, nil,
			engine.Entity.new{alpha=100, display='', color_br=20, color_bg=220, color_bb=70},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			false
		)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[A furious poison storm rages around the caster, poisoning all creatures inside for %0.2f nature damage in 6 turns in a radius of %d for %d turns.
		Poisoning is cumulative, the longer they stay in the higher the poison damage they take.
		The damage will increase with the Magic stat]]):format(damDesc(self, DamageType.NATURE, self:combatTalentSpellDamage(t, 12, 130)), self:getTalentRadius(t), 5 + self:getTalentLevel(t))
	end,
}
