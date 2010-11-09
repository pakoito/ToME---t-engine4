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
	name = "Dark Ritual",
	type = {"corruption/blight", 1},
	mode = "sustained",
	require = corrs_req1,
	points = 5,
	sustain_vim = 20,
	cooldown = 30,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		local ret = {
			per = self:addTemporaryValue("combat_critical_power", self:combatTalentSpellDamage(t, 20, 60) / 100),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_spellcrit", p.per)
		return true
	end,
	info = function(self, t)
		return ([[Increasing your spell critical damage multiplier by %d%%.
		The damage will increase with your Magic stat.]]):
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
	range = 20,
	requires_target = true,
	action = function(self, t)
		local tg = {type="ball", radius=3, range=self:getTalentRange(t), talent=t}
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

				if eff[1] == "effect" then
					target:removeEffect(eff[2])
				else
					target:forceUseTalent(eff[2], {ignore_energy=true})
				end
			end
		end, nil, {type="slime"})
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Project a corrupted blast of power that deals %0.2f blight damage and removes %d magical or physical effects from any creatures caught in the area.
		The damage will increase with Magic stat.]]):format(damDesc(self, DamageType.BLIGHT, self:combatTalentSpellDamage(t, 10, 120)), self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Corrosive Worm",
	type = {"corruption/blight", 3},
	require = corrs_req3,
	points = 5,
	cooldown = 10,
	vim = 12,
	range = 20,
	requires_target = true,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			target:setEffect(target.EFF_CORROSIVE_WORM, 10, {src=self, dam=self:combatTalentSpellDamage(t, 10, 60), explosion=self:spellCrit(self:combatTalentSpellDamage(t, 10, 230))})
		end)
		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		return ([[Infect your target with a corrosive worm that deals %0.2f acid damage per turn.
		If the target dies while the worm is inside it will explode doing %0.2f acid damage in a radius of 4.
		The damage will increase with Magic stat.]]):
		format(damDesc(self, DamageType.ACID, self:combatTalentSpellDamage(t, 10, 60)), damDesc(self, DamageType.ACID, self:combatTalentSpellDamage(t, 10, 230)))
	end,
}

newTalent{
	name = "Blight Storm",
	type = {"corruption/blight", 4},
	mode = "sustained",
	require = corrs_req4,
	points = 5,
	sustain_vim = 60,
	cooldown = 30,
	on_crit = function(self, t)
		self:setEffect(self.EFF_BLOOD_FURY, 5, {power=self:combatTalentSpellDamage(t, 10, 30)})
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/slime")
		local ret = {
			per = self:addTemporaryValue("combat_spellcrit", self:combatTalentSpellDamage(t, 10, 24)),
		}
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("combat_spellcrit", p.per)
		return true
	end,
	info = function(self, t)
		return ([[Concentrate on the corruption you bring, increasing your spell critical chance by %d%%.
		Each time your spells are critical you enter a blood rage for 5 turns, increasing your blight damage by %d%%.
		The damage will increase with your Magic stat.]]):
		format(self:combatTalentSpellDamage(t, 10, 24), self:combatTalentSpellDamage(t, 10, 30))
	end,
}
