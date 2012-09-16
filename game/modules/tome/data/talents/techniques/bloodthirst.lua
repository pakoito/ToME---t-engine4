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
	name = "Bloodbath",
	type = {"technique/bloodthirst", 1},
	require = techs_req_high1,
	points = 5,
	mode = "passive",
	getRegen = function (self, t) return self:getTalentLevel(t) end,
	getMax = function(self, t) return self:getTalentLevel(t)*5 end,
	do_bloodbath = function(self, t)
		self:setEffect(self.EFF_BLOODBATH, 5 + self:getTalentLevelRaw(t), {regen=t.getRegen(self, t), max=t.getMax(self, t), hp=math.floor(self:getTalentLevel(t) * 2)})
	end,
	info = function(self, t)
		local regen = t.getRegen(self, t)
		local max_regen = t.getMax(self, t)
		return ([[Delight in spilling the blood of your foes.  After scoring a critical hit your maximum hit points will be increased by %d%%, your life regeneration by %0.2f per turn, and your stamina regeneration by %0.2f per turn.
		The life and stamina regeneration will stack up to five times for a maximum of %0.2f and %0.2f each turn, respectively.]]):
		format(math.floor(self:getTalentLevel(t) * 2), regen, regen/5, max_regen, max_regen/5)
	end,
}

newTalent{
	name = "Mortal Terror",
	type = {"technique/bloodthirst", 2},
	require = techs_req_high2,
	points = 5,
	mode = "passive",
	do_terror = function(self, t, target, dam)
		if dam < target.max_life * (20 + (30 - self:getTalentLevelRaw(t) * 5)) / 100 then return end

		local weapon = target:getInven("MAINHAND")
		if type(weapon) == "boolean" then weapon = nil end
		if weapon then weapon = weapon[1] and weapon[1].combat end
		if not weapon or type(weapon) ~= "table" then weapon = nil end
		weapon = weapon or target.combat

		if target:canBe("stun") then
			target:setEffect(target.EFF_DAZED, 5, {apply_power=self:combatPhysicalpower()})
		else
			game.logSeen(target, "%s resists the terror!", target.name:capitalize())
		end
	end,
	on_learn = function(self, t)
		self.combat_physcrit = self.combat_physcrit + 2.8
	end,
	on_unlearn = function(self, t)
		self.combat_physcrit = self.combat_physcrit - 2.8
	end,
	info = function(self, t)
		return ([[Your mighty blows inspire utter terror on your foes. Any melee strike you do that deals more than %d%% of the target's total life puts them in a mortal terror, dazing them for 5 turns.
		Your critical strike chance also increase by %d%%.
		Daze chance increase with your Strength stat.]]):
		format(20 + (30 - self:getTalentLevelRaw(t) * 5), self:getTalentLevelRaw(t) * 2.8)
	end,
}

newTalent{
	name = "Bloodrage",
	type = {"technique/bloodthirst", 3},
	require = techs_req_high3,
	points = 5,
	mode = "passive",
	on_kill = function(self, t)
		self:setEffect(self.EFF_BLOODRAGE, math.floor(5 + self:getTalentLevel(t)), {max=math.floor(self:getTalentLevel(t) * 6), inc=2})
	end,
	info = function(self, t)
		return ([[Each time one of your foes bites the dust you feel a surge of power, increasing your strength by 2 up to a maximum of %d for %d turns.]]):
		format(math.floor(self:getTalentLevel(t) * 6), math.floor(5 + self:getTalentLevel(t)))
	end,
}

newTalent{
	name = "Unstoppable",
	type = {"technique/bloodthirst", 4},
	require = techs_req_high4,
	points = 5,
	cooldown = 45,
	stamina = 120,
	tactical = { DEFEND = 5, CLOSEIN = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_UNSTOPPABLE, 2 + self:getTalentLevelRaw(t), {hp_per_kill=math.floor(self:getTalentLevel(t) * 3.5)})
		return true
	end,
	info = function(self, t)
		return ([[You enter a battle frenzy for %d turns. During the time you can not use items, healing has no effect and your health can not drop below 1.
		At the end of the frenzy you regain %d%% of your health per foes slain during the frenzy.]]):
		format(2 + self:getTalentLevelRaw(t), math.floor(self:getTalentLevel(t) * 3.5))
	end,
}
