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

newTalent{
	name = "Feed",
	type = {"cursed/dark-sustenance", 1},
	require = cursed_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 6,
	range = 15,
	requires_target = true,
	getHateGain = function(self, t)
		return math.sqrt(self:getTalentLevel(t)) * 0.2 + self:getWil(0.15)
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end

		if self:reactionToward(target) >= 0 or target.summoner == self then
			game.logPlayer(self, "You can only gain sustenance from your foes!");
			return nil
		end

		-- remove old effect
		if self:hasEffect(self.EFF_FEED_HATE) then
			self:removeEffect(self.EFF_FEED_HATE)
		end
		
		local hateGain = t.getHateGain(self, t)
		local constitutionGain = 0
		local lifeRegenGain = 0
		local damageGain = 0
		local resistGain = 0
		
		local tFeedHealth = self:getTalentFromId(self.T_FEED_HEALTH)
		if tFeedHealth and self:getTalentLevelRaw(tFeedHealth) > 0 then
			constitutionGain = tFeedHealth.getConstitutionGain(self, tFeedHealth, target)
			lifeRegenGain = tFeedHealth.getLifeRegenGain(self, tFeedHealth)
		end
		
		local tFeedPower = self:getTalentFromId(self.T_FEED_POWER)
		if tFeedPower and self:getTalentLevelRaw(tFeedPower) > 0 then
			damageGain = tFeedPower.getDamageGain(self, tFeedPower, target)
		end
		
		local tFeedStrengths = self:getTalentFromId(self.T_FEED_STRENGTHS)
		if tFeedStrengths and self:getTalentLevelRaw(tFeedStrengths) > 0 then
			resistGain = tFeedStrengths.getResistGain(self, tFeedStrengths, target)
		end

		self:setEffect(self.EFF_FEED, 99999, { target=target, hateGain=hateGain, constitutionGain=constitutionGain, lifeRegenGain=lifeRegenGain, damageGain=damageGain, resistGain=resistGain, extension=0 })

		return true
	end,
	info = function(self, t)
		local hateGain = t.getHateGain(self, t)
		return ([[Feed from the essence of your enemy. Draws %0.2f hate per turn from a targeted foe as long as the foe remains in your line of sight.
		Improves with the Willpower stat.]]):format(hateGain)
	end,
}

newTalent{
	name = "Feed Health",
	type = {"cursed/dark-sustenance", 2},
	mode = "passive",
	require = cursed_wil_req2,
	points = 5,
	getConstitutionGain = function(self, t, target)
		local gain = math.floor((6 + self:getWil(6)) * math.sqrt(self:getTalentLevel(t)) * 0.392)
		if target then
			-- return capped gain
			return math.min(gain, math.floor(target:getCon() * 0.75))
		else
			-- return max gain
			return gain
		end
	end,
	getLifeRegenGain = function(self, t, target)
		return self.max_life * (math.sqrt(self:getTalentLevel(t)) * 0.012 + self:getWil(0.01))
	end,
	info = function(self, t)
		local constitutionGain = t.getConstitutionGain(self, t)
		local lifeRegenGain = t.getLifeRegenGain(self, t)
		return ([[Enhances your feeding by transferring %d constitution and %0.1f life per turn from a targeted foe to you.
		Improves with the Willpower stat.]]):format(constitutionGain, lifeRegenGain)
	end,
}

newTalent{
	name = "Feed Power",
	type = {"cursed/dark-sustenance", 3},
	mode = "passive",
	require = cursed_wil_req3,
	points = 5,
	getDamageGain = function(self, t)
		return math.sqrt(self:getTalentLevel(t)) * 5 + self:getWil(5)
	end,
	info = function(self, t)
		local damageGain = t.getDamageGain(self, t)
		return ([[Enhances your feeding by reducing your targeted foe's damage by %d%% and increasing yours by the same amount.
		Improves with the Willpower stat.]]):format(damageGain)
	end,
}

newTalent{
	name = "Feed Strengths",
	type = {"cursed/dark-sustenance", 4},
	mode = "passive",
	require = cursed_wil_req4,
	points = 5,
	getResistGain = function(self, t)
		return math.sqrt(self:getTalentLevel(t)) * 22 + self:getWil(15)
	end,
	getExtension = function(self, t)
		return math.floor(self:getTalentLevel(t) - 1)
	end,
	info = function(self, t)
		local resistGain = t.getResistGain(self, t)
		return ([[Enhances your feeding by reducing your targeted foe's positive resistances by %d%% and increasing yours by the same amount.
		Improves with the Willpower stat.]]):format(resistGain)
	end,
}
