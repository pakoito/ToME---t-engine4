-- ToME - Tales of Middle-Earth
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

local function getHateMultiplier(self, min, max)
	return (min + ((max - min) * self.hate / 10))
end

newTalent{
	name = "Unnatural Body",
	type = {"cursed/cursed-form", 1},
	mode = "passive",
	require = cursed_str_req1,
	points = 5,
	on_learn = function(self, t)
		-- assume on only learning one point at a time (true when this was written)
		local level = self:getTalentLevelRaw(t)
		if level == 1 then
			-- baseline
			self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 25
			self.combat_spellresist = self.combat_spellresist - 10
			self.max_life = self.max_life + 15
		elseif level == 2 then
			self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 5
			self.combat_spellresist = self.combat_spellresist + 2
			self.max_life = self.max_life + 15
		elseif level == 3 then
			self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 5
			self.combat_spellresist = self.combat_spellresist + 2
			self.max_life = self.max_life + 15
		elseif level == 4 then
			self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 5
			self.combat_spellresist = self.combat_spellresist + 2
			self.max_life = self.max_life + 15
		elseif level == 5 then
			self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 5
			self.combat_spellresist = self.combat_spellresist + 2
			self.max_life = self.max_life + 15
		end
		return true
	end,
	on_unlearn = function(self, t)
		-- assume on only learning one point at a time (true when this was written)
		local level = self:getTalentLevelRaw(t)
		if not level or level == 0 then
			-- baseline
			self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) + 25
			self.combat_spellresist = self.combat_spellresist + 10
			self.max_life = self.max_life - 15
		elseif level == 1 then
			self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 5
			self.combat_spellresist = self.combat_spellresist - 2
			self.max_life = self.max_life - 15
		elseif level == 2 then
			self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 5
			self.combat_spellresist = self.combat_spellresist - 2
			self.max_life = self.max_life - 15
		elseif level == 3 then
			self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 5
			self.combat_spellresist = self.combat_spellresist - 2
			self.max_life = self.max_life - 15
		elseif level == 4 then
			self.resists[DamageType.FIRE] = (self.resists[DamageType.FIRE] or 0) - 5
			self.combat_spellresist = self.combat_spellresist - 2
			self.max_life = self.max_life - 15
		end

		return true
	end,
	do_regenLife  = function(self, t)
		heal = math.sqrt(self:getTalentLevel(t) * 2) * self.max_life * 0.003
		if heal > 0 then
			self:heal(heal)
		end
	end,
	info = function(self, t)
		heal = math.sqrt(self:getTalentLevel(t) * 2) * self.max_life * 0.003
		local level = self:getTalentLevelRaw(t)
		if level == 1 then
			return ([[The curse has twisted your body into an unnatural form.
			(-25%% fire resistance, -10 spell save, +15 maximum life, +%0.1f life per turn).]]):format(heal)
		elseif level == 2 then
			return ([[The curse has twisted your body into an unnatural form.
			(-20%% fire resistance, -8 spell save, +15 maximum life, +%0.1f life per turn).]]):format(heal)
		elseif level == 3 then
			return ([[The curse has twisted your body into an unnatural form.
			(-15%% fire resistance, -6 spell save, +15 maximum life, +%0.1f life per turn).]]):format(heal)
		elseif level == 4 then
			return ([[The curse has twisted your body into an unnatural form.
			(-10%% fire resistance, -4 spell save, +15 maximum life, +%0.1f life per turn).]]):format(heal)
		else
			return ([[The curse has twisted your body into an unnatural form.
			(-5%% fire resistance, -2 spell save, +15 maximum life, +%0.1f life per turn).]]):format(heal)
		end
	end,
}

--newTalent{
--	name = "Obsession",
--	type = {"cursed/cursed-form", 2},
--	require = cursed_str_req2,
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
--	require = cursed_str_req2,
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
	name = "Relentless",
	type = {"cursed/cursed-form", 2},
	mode = "passive",
	require = cursed_str_req2,
	points = 5,
	on_learn = function(self, t)
		self.fear_immune = self.stun_immune or 0 + 0.15
		self.confusion_immune = self.stun_immune or 0 + 0.15
		self.knockback_immune = self.knockback_immune or 0 + 0.15
		self.stun_immune = self.stun_immune or 0 + 0.15
		return true
	end,
	on_unlearn = function(self, t)
		self.fear_immune = self.stun_immune or 0 + 0.15
		self.confusion_immune = self.stun_immune or 0 + 0.15
		self.knockback_immune = self.knockback_immune or 0 + 0.15
		self.stun_immune = self.stun_immune or 0 + 0.15
		return true
	end,
	info = function(self, t)
		return ([[Your thirst for blood drives your movements. (+%d%% confusion, fear, knockback and stun immunity)]]):format(self:getTalentLevelRaw(t) * 15)
	end,
}

newTalent{
	name = "Seethe",
	type = {"cursed/cursed-form", 3},
	random_ego = "utility",
	require = cursed_str_req3,
	points = 5,
	cooldown = 400,
	action = function(self, t)
		local increase = 2 + self:getTalentLevel(t) * 0.9
		hate = math.min(self.max_hate, self.hate + increase)
		self:incHate(hate)

		local damage = self.max_life * 0.25
		self:project({type="hit"}, self.x, self.y, DamageType.BLIGHT, damage)
		game.level.map:particleEmitter(self.x, self.y, 5, "fireflash", {radius=5, tx=self.x, ty=self.y})
		game:playSoundNear(self, "talents/fireflash")
		return true
	end,
	info = function(self, t)
		local increase = 2 + self:getTalentLevel(t) * 0.9
		local damage = self.max_life * 0.25
		return ([[Focus your rage gaining %0.1f hate at the cost of %d life.]]):format(increase, damage)
	end,
}

newTalent{
	name = "Enrage",
	type = {"cursed/cursed-form", 4},
	require = cursed_str_req4,
	points = 5,
	rage = 0.1,
	cooldown = 50,
	action = function(self, t)
		local life = 50 + self:getTalentLevel(t) * 50
		self:setEffect(self.EFF_INCREASED_LIFE, 20, { life = life })
		return true
	end,
	info = function(self, t)
		local life = 50 + self:getTalentLevel(t) * 50
		return ([[In a burst of rage you become an even more fearsome opponent gaining %d extra life for 20 turns.]]):format(life)
	end,
}


