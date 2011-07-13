-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

local function getHateMultiplier(self, min, max)
	return (min + ((max - min) * math.min(self.hate, 10) / 10))
end

local function combatTalentDamage(self, t, min, max)
	return self:combatTalentSpellDamage(t, min, max, (self.level + self:getWil()) * 1.2)
end

newTalent{
	name = "Unnatural Body",
	type = {"cursed/cursed-form", 1},
	mode = "passive",
	require = cursed_wil_req1,
	points = 5,
	on_learn = function(self, t)
		return true
	end,
	on_unlearn = function(self, t)
		return true
	end,
	getHealPerKill = function(self, t)
		return combatTalentDamage(self, t, 15, 55)
	end,
	getRegenRate = function(self, t)
		return 3 + math.sqrt(self:getTalentLevel(t) * 2) * math.min(1000, self.max_life) * 0.006
	end,
	getResist = function(self, t)
		return -18 + (self:getTalentLevel(t) * 3) + (18 * getHateMultiplier(self, 0, 1))
	end,
	do_regenLife  = function(self, t)
		-- initialize
		if (self.unnatural_body_healing_factor or 0) == 0 then
			self.unnatural_body_healing_factor = -0.5
			self.healing_factor = (self.healing_factor or 1) + self.unnatural_body_healing_factor
		end
	
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

		-- update resists as well
		local oldResist = self.unnatural_body_resist or 0
		local newResist = t.getResist(self, t)
		self.resists.all = (self.resists.all or 0) - oldResist + newResist
		self.unnatural_body_resist = newResist
	end,
	on_kill = function(self, t, target)
		if target and target.max_life then
			heal = math.min(t.getHealPerKill(self, t), target.max_life)
			if heal > 0 then
				self.unnatural_body_heal = math.min(self.life, (self.unnatural_body_heal or 0) + heal)
			end
		end
	end,
	info = function(self, t)
		local healPerKill = t.getHealPerKill(self, t)
		local regenRate = t.getRegenRate(self, t)
		local resist = -18 + (self:getTalentLevel(t) * 3)

		local modifier1, modifier2 = "more", "more"
		if resist > 0 then modifier1 = "less" end
		if resist + 18 > 0 then modifier2 = "less" end
		return ([[Your body's strength is fed by your hatred. With each kill you regenerate %d life at a rate of %0.1f life per turn. This healing cannot be reduced but most other forms of healing are reduced by 50%%. You also take %d%% %s damage (at 0 Hate) to %d%% %s damage (at 10+ Hate).
		Healing from kills improves with the Willpower stat.]]):format(healPerKill, regenRate, math.abs(resist), modifier1, math.abs(resist + 18), modifier2)
	end,
}

--newTalent{
--	name = "Obsession",
--	type = {"cursed/cursed-form", 2},
--	require = cursed_wil_req2,
--	mode = "passive",
--	points = 5,
--	on_learn = function(self, t)
--		self.hate_per_kill = self.hate_per_kill + 0.1
--	end,
--	on_unlearn = function(self, t)
--		self.hate_per_kill = self.hate_per_kill - 0.1
--	end,
--	info = function(self, t)
--		return ([[Your suffering will become theirs. For every life that is taken you gain an extra %0.1f hate.]]):format(self:getTalentLevelRaw(t) * 0.1)
--	end
--}

--newTalent{
--	name = "Suffering",
--	type = {"cursed/cursed-form", 2},
--	require = cursed_wil_req2,
--	mode = "passive",
--	points = 5,
--	on_learn = function(self, t)
--		return true
--	end,
--	on_unlearn = function(self, t)
--		return true
--	end,
--	do_onTakeHit = function(self, t, damage)
--		if damage > 0 then
--			local hatePerLife = (1 + self:getTalentLevel(t)) / (self.max_life * 1.5)
--			self.hate = math.max(self.max_hate, self.hate + damage * hatePerLife)
--		end
--	end,
--	info = function(self, t)
--		local hatePerLife = (1 + self:getTalentLevel(t)) / (self.max_life * 1.5)
--		return ([[Your suffering will become theirs. For every %d life that is taken, you gain 1 hate.]]):format(1 / hatePerLife)
--	end
--}

newTalent{
	name = "Seethe",
	type = {"cursed/cursed-form", 2},
	random_ego = "utility",
	require = cursed_wil_req2,
	points = 5,
	cooldown = 400,
	tactical = { BUFF = 1 },
	getHateGain = function(self, t)
		return (math.sqrt(self:getTalentLevel(t)) - 0.5) * 3
	end,
	action = function(self, t)
		self:incHate(t.getHateGain(self, t))

		game.level.map:particleEmitter(self.x, self.y, 5, "fireflash", {radius=1, tx=self.x, ty=self.y})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local hateGain = t.getHateGain(self, t)
		return ([[Focus your rage gaining %0.1f hate.]]):format(hateGain)
	end,
}

newTalent{
	name = "Relentless",
	type = {"cursed/cursed-form", 3},
	mode = "passive",
	require = cursed_wil_req3,
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
	name = "Enrage",
	type = {"cursed/cursed-form", 4},
	require = cursed_wil_req4,
	points = 5,
	rage = 0.1,
	cooldown = 50,
	tactical = { DEFEND = 2 },
	action = function(self, t)
		local life = 50 + self:getTalentLevel(t) * 50
		self:setEffect(self.EFF_INCREASED_LIFE, 20, { life = life })
		return true
	end,
	info = function(self, t)
		local life = 50 + self:getTalentLevel(t) * 50
		return ([[In a burst of rage you become an even more fearsome opponent, gaining %d extra life for 20 turns.]]):format(life)
	end,
}


