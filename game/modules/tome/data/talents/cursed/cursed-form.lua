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

local function combatTalentDamage(self, t, min, max)
	return self:combatTalentSpellDamage(t, min, max, (self.level + self:getWil()) * 1.2)
end

newTalent{
	name = "Unnatural Body",
	type = {"cursed/cursed-form", 1},
	mode = "passive",
	require = cursed_wil_req1,
	points = 5,
	no_unlearn_last = true,
	on_learn = function(self, t)
		return true
	end,
	on_unlearn = function(self, t)
		return true
	end,
	getHealPerKill = function(self, t)
		return combatTalentDamage(self, t, 15, 50)
	end,
	getMaxUnnaturalBodyHeal = function(self, t)
		return t.getHealPerKill(self, t) * 2
	end,
	getRegenRate = function(self, t)
		return 3 + math.sqrt(self:getTalentLevel(t) * 2) * math.min(1000, self.max_life) * 0.006
	end,
	updateHealingFactor = function(self, t)
		local change = -0.5 + math.min(100, self:getHate()) * .005
		self.healing_factor = (self.healing_factor or 1) - (self.unnatural_body_healing_factor or 0) + change
		self.unnatural_body_healing_factor = change
	end,
	do_regenLife  = function(self, t)
		-- update healing factor
		t.updateHealingFactor(self, t)

		-- heal
		local maxHeal = self.unnatural_body_heal or 0
		if maxHeal > 0 then
			local heal = math.min(t.getRegenRate(self, t), maxHeal)
			local temp = self.healing_factor
			self.healing_factor = 1
			self:heal(heal)
			self.healing_factor = temp

			self.unnatural_body_heal = math.max(0, (self.unnatural_body_heal or 0) - heal)
		end
	end,
	on_kill = function(self, t, target)
		if target and target.max_life then
			heal = math.min(t.getHealPerKill(self, t), target.max_life)
			if heal > 0 then
				self.unnatural_body_heal = math.min(self.life, (self.unnatural_body_heal or 0) + heal)
				self.unnatural_body_heal = math.min(self.unnatural_body_heal, t.getMaxUnnaturalBodyHeal(self, t))
			end
		end
	end,
	info = function(self, t)
		local healPerKill = t.getHealPerKill(self, t)
		local maxUnnaturalBodyHeal = t.getMaxUnnaturalBodyHeal(self, t)
		local regenRate = t.getRegenRate(self, t)

		return ([[Your body's strength is fed by your hatred. This causes most forms of healing to be 50%% effective (at 0 Hate) to 100%% effective (at 100+ Hate). In addition, after each kill you regenerate %d life (up to a maximum of %d) at a rate of %0.1f life per turn. This healing cannot be reduced by your hate.
		Healing from kills improves with the Willpower stat.]]):format(healPerKill, maxUnnaturalBodyHeal, regenRate)
	end,
}

newTalent{
	name = "Relentless",
	type = {"cursed/cursed-form", 2},
	mode = "passive",
	require = cursed_wil_req2,
	points = 5,
	on_learn = function(self, t)
		self:attr("fear_immune", 0.15)
		self:attr("confusion_immune", 0.15)
		self:attr("knockback_immune", 0.15)
		self:attr("stun_immune", 0.15)
		return true
	end,
	on_unlearn = function(self, t)
		self:attr("fear_immune", -0.15)
		self:attr("confusion_immune", -0.15)
		self:attr("knockback_immune", -0.15)
		self:attr("stun_immune", -0.15)
		return true
	end,
	info = function(self, t)
		return ([[Your thirst for blood drives your movements. (+%d%% confusion, fear, knockback and stun immunity)]]):format(self:getTalentLevelRaw(t) * 15)
	end,
}

newTalent{
	name = "Seethe",
	type = {"cursed/cursed-form", 3},
	mode = "passive",
	require = cursed_wil_req3,
	points = 5,
	getIncDamageChange = function(self, t, increase)
		return math.min(30, math.floor(math.sqrt(self:getTalentLevel(t)) * 2 * increase))
	end,
	info = function(self, t)
		local incDamageChangeMax = t.getIncDamageChange(self, t, 5)
		return ([[You have learned to hold onto your hate and use your suffering to fuel your body's rage. Every turn you take damage, the damage you inflict increases until it reaches a maximum of +%d%% after 5 turns. Any turn in which you do not take damage will reduce the bonus.]]):format(incDamageChangeMax)
	end
}

newTalent{
	name = "Grim Resolve",
	type = {"cursed/cursed-form", 4},
	require = cursed_wil_req4,
	mode = "passive",
	points = 5,
	getStatChange = function(self, t, increase)
		return math.min(18, math.floor(math.sqrt(self:getTalentLevel(t) * 1) * increase))
	end,
	getNeutralizeChance = function(self, t)
		return math.min(30, math.floor(math.sqrt(self:getTalentLevel(t)) * 10))
	end,
	info = function(self, t)
		local statChangeMax = t.getStatChange(self, t, 5)
		local neutralizeChance = t.getNeutralizeChance(self, t)
		return ([[You rise to meet the pain that others would inflict on you. Every turn you take damage, your Strength and Willpower increase until it reaches maximum of +%d after 5 turns. Any turn in which you do not take damage will reduce the bonus. While in effect, your body also has a %d%% chance to overcome poisons and diseases each turn.]]):format(statChangeMax, neutralizeChance)
	end,
}


