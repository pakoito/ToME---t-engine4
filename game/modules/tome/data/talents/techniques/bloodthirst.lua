-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	name = "Mortal Terror",
	type = {"technique/bloodthirst", 1},
	require = techs_req_high1,
	points = 5,
	mode = "passive",
	threshold = function(self,t) return self:combatTalentLimit(t, 10, 45, 25) end, -- Limit >10%
	getCrit = function(self, t) return self:combatTalentScale(t, 2.8, 14) end,
	do_terror = function(self, t, target, dam)
		if dam < target.max_life * t.threshold(self, t) / 100 then return end

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
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "combat_physcrit", t.getCrit(self, t))
	end,
	info = function(self, t)
		return ([[Your mighty blows inspire utter terror on your foes. Any melee strike you do that deals more than %d%% of the target's total life puts them in a mortal terror, dazing them for 5 turns.
		Your critical strike chance also increase by %d%%.
		The daze chance increase with your Physical Power.]]):
		format(t.threshold(self, t), self:getTalentLevelRaw(t) * 2.8)
	end,
}

newTalent{
	name = "Bloodbath",
	type = {"technique/bloodthirst", 2},
	require = techs_req_high2,
	points = 5,
	mode = "passive",
	getHealth = function(self,t) return self:combatTalentLimit(t, 50, 2, 10)  end,  -- Limit max health increase to <+50%
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getRegen = function (self, t) return self:combatTalentScale(t, 1.7, 5) end,
	getMax = function(self, t) return 5*self:combatTalentScale(t, 1.7, 5) end,
	-- called by _M:attackTargetWith in mod.class.interface.Combat.lua
	do_bloodbath = function(self, t)
		self:setEffect(self.EFF_BLOODBATH, t.getDuration(self, t), {regen=t.getRegen(self, t), max=t.getMax(self, t), hp=t.getHealth(self,t)})
	end,
	info = function(self, t)
		local regen = t.getRegen(self, t)
		local max_regen = t.getMax(self, t)
		local max_health = t.getHealth(self,t)
		return ([[Delight in spilling the blood of your foes.  After scoring a critical hit, your maximum hit points will be increased by %d%%, your life regeneration by %0.2f per turn, and your stamina regeneration by %0.2f per turn for %d turns.
		The life and stamina regeneration will stack up to five times, for a maximum of %0.2f and %0.2f each turn, respectively.]]):
		format(t.getHealth(self, t), regen, regen/5, t.getDuration(self, t),max_regen, max_regen/5)
	end,
}

newTalent{
	name = "Bloody Butcher",
	type = {"technique/bloodthirst", 3},
	require = techs_req_high3,
	points = 5,
	mode = "passive",
	getDam = function(self, t) return self:combatScale(self:getStr(5, true) * self:getTalentLevel(t), 5, 0, 40, 35) end,
	getResist = function(self,t) return self:combatTalentLimit(t, 50, 10, 40) end,
	info = function(self, t)
		return ([[You delight in the inflicting of wounds, providing %d physical power.
		In addition when you make a creature bleed its physical damage resistance is reduced by %d%% (but never below 0%%).
		Physical power depends on your Strength stat.]]):
		format(t.getDam(self, t), t.getResist(self, t))
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
	getHealPercent = function(self,t) return self:combatTalentLimit(t, 50, 3.5, 17.5) end, -- Limit <50%
	getDuration = function(self, t) return math.floor(self:combatTalentLimit(t, 25, 3, 7, true)) end, -- Limit < 25
	action = function(self, t)
		self:setEffect(self.EFF_UNSTOPPABLE, t.getDuration(self, t), {hp_per_kill=t.getHealPercent(self,t)})
		return true
	end,
	info = function(self, t)
		return ([[You enter a battle frenzy for %d turns. During that time, you can not use items, healing has no effect, and your health cannot drop below 1.
		At the end of the frenzy, you regain %d%% of your health per foe slain during the frenzy.
		While Unstoppable is active, Berserker Rage critical bonus is disabled as you lose the thrill of the risk of death.]]):
		format(t.getDuration(self, t), t.getHealPercent(self,t))
	end,
}
