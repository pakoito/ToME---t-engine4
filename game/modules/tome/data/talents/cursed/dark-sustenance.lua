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
	name = "Feed Hate",
	type = {"cursed/dark-sustenance", 1},
	require = cursed_wil_req1,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	range = 15,
	requires_target = true,
	getHateGain = function(self, t)
		return self:getWil(0.3) + self:getTalentLevel(t) * 0.1
	end,
	getExtension = function(self, t)
		return math.floor(self:getTalentLevel(t) - 1)
	end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t)}
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		
		if self:reactionToward(target) >= 0 then
			logPlayer(self, "You can only gain sustenance from your foes!");
		end
		
		-- remove old effect
		if self:hasEffect(self.EFF_FEED_HATE) then
			self:removeEffect(self.EFF_FEED_HATE)
		end
		
		local hateGain = t.getHateGain(self, t)
		local extension = t.getExtension(self, t)
		self:setEffect(self.EFF_FEED_HATE, 99999, { target=target, hateGain=hateGain, extension=extension })

		return true
	end,
	info = function(self, t)
		local hateGain = t.getHateGain(self, t)
		local extension = t.getExtension(self, t)
		local extensionText = ""
		if extension > 0 then
			return ([[Draws %0.2f hate per turn from a targeted foe as long as the foe remains in your line of sight. You will continue to gain hate for %d turns after the link is severed.
			Improves with the Willpower stat.]]):format(hateGain, extension)
		else
			return ([[Draws %0.2f hate per turn from a targeted foe as long as the foe remains in your line of sight.
			Improves with the Willpower stat.]]):format(hateGain)
		end
	end,
}

newTalent{
	name = "Feed Health",
	type = {"cursed/dark-sustenance", 2},
	require = cursed_wil_req2,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	range = 15,
	requires_target = true,
	getConstitutionGain = function(self, t, target)
		local gain = 2 + math.floor(self:getWil(18) * (0.3 + self:getTalentLevel(t) * 0.2))
		if target then
			-- return capped gain
			return math.min(gain, math.floor(target:getCon() * 0.75))
		else
			-- return max gain
			return gain
		end
	end,
	getLifeRegenGain = function(self, t, target)
		return self.max_life * (0.003 + self:getWil(0.005) + self:getTalentLevel(t) * 0.005)
	end,
	getExtension = function(self, t)
		return math.floor(self:getTalentLevel(t) - 1)
	end,
	action = function(self, t)
		local tg = { type="hit", range=self:getTalentRange(t) }
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		
		if self:reactionToward(target) >= 0 then
			logPlayer(self, "You can only gain sustenance from your foes!");
		end
		
		-- remove old effect
		if self:hasEffect(self.EFF_FEED_HEALTH) then
			self:removeEffect(self.EFF_FEED_HEALTH)
		end
		
		local constitutionGain = t.getConstitutionGain(self, t, target)
		local lifeRegenGain = t.getLifeRegenGain(self, t)
		local extension = t.getExtension(self, t)
		self:setEffect(self.EFF_FEED_HEALTH, 99999, { target=target, constitutionGain=constitutionGain, lifeRegenGain=lifeRegenGain, extension=extension })

		return true
	end,
	info = function(self, t)
		local constitutionGain = t.getConstitutionGain(self, t)
		local lifeRegenGain = t.getLifeRegenGain(self, t)
		local extension = t.getExtension(self, t)
		if extension > 0 then
			return ([[Transfers %d constitution and %0.1f life per turn from a targeted foe to you as long as the foe remains in your line of sight. You will continue to gain life for %d turns after the link is severed.
			Improves with the Willpower stat.]]):format(constitutionGain, lifeRegenGain, extension)
		else
			return ([[Transfers %d constitution and %0.1f life per turn from a targeted foe to you as long as the foe remains in your line of sight.
			Improves with the Willpower stat.]]):format(constitutionGain, lifeRegenGain)
		end
	end,
}

newTalent{
	name = "Feed Power",
	type = {"cursed/dark-sustenance", 3},
	require = cursed_wil_req3,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	range = 15,
	requires_target = true,
	getDamageGain = function(self, t)
		return self:getWil(10) + self:getTalentLevel(t) * 5
	end,
	getExtension = function(self, t)
		return math.floor(self:getTalentLevel(t) - 1)
	end,
	action = function(self, t)
		local tg = { type="hit", range=self:getTalentRange(t) }
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		
		if self:reactionToward(target) >= 0 then
			logPlayer(self, "You can only gain sustenance from your foes!");
		end
		
		-- remove old effect
		if self:hasEffect(self.EFF_FEED_POWER) then
			self:removeEffect(self.EFF_FEED_POWER)
		end
		
		local damageGain = t.getDamageGain(self, t)
		local extension = t.getExtension(self, t)
		self:setEffect(self.EFF_FEED_POWER, 99999, { target=target, damageGain=damageGain, extension=extension })

		return true
	end,
	info = function(self, t)
		local damageGain = t.getDamageGain(self, t)
		local extension = t.getExtension(self, t)
		if extension > 0 then
			return ([[Reduces your targeted foe's damage by %d%% and increases yours by the same amount as long as the foe remains in your line of sight. You will continue to gain power for %d turns after the link is severed.
			Improves with the Willpower stat.]]):format(damageGain, extension)
		else
			return ([[Reduces your targeted foe's damage by %d%% and increases yours by the same amount as long as the foe remains in your line of sight.
			Improves with the Willpower stat.]]):format(damageGain)
		end
	end,
}

newTalent{
	name = "Feed Strengths",
	type = {"cursed/dark-sustenance", 4},
	require = cursed_wil_req4,
	points = 5,
	random_ego = "attack",
	cooldown = 8,
	range = 15,
	requires_target = true,
	getResistGain = function(self, t)
		return 20 + self:getWil(10) + self:getTalentLevel(t) * 7
	end,
	getExtension = function(self, t)
		return math.floor(self:getTalentLevel(t) - 1)
	end,
	action = function(self, t)
		local tg = { type="hit", range=self:getTalentRange(t) }
		local x, y, target = self:getTarget(tg)
		if not x or not y or not target then return nil end
		
		if self:reactionToward(target) >= 0 then
			logPlayer(self, "You can only gain sustenance from your foes!");
		end
		
		-- remove old effect
		if self:hasEffect(self.EFF_FEED_STRENGTHS) then
			self:removeEffect(self.EFF_FEED_STRENGTHS)
		end
		
		local resistGain = t.getResistGain(self, t)
		local extension = t.getExtension(self, t)
		self:setEffect(self.EFF_FEED_STRENGTHS, 99999, { target=target, resistGain=resistGain, extension=extension })

		return true
	end,
	info = function(self, t)
		local resistGain = t.getResistGain(self, t)
		local extension = t.getExtension(self, t)
		if extension > 0 then
			return ([[Reduces your targeted foe's positive resistances by %d%% and increases yours by the same amount as long as the foe remains in your line of sight. You will continue to gain power for %d turns after the link is severed.
			Improves with the Willpower stat.]]):format(resistGain, extension)
		else
			return ([[Reduces your targeted foes positive resistances by %d%% and increases yours by the same amount as long as the foe remains in your line of sight.
			Improves with the Willpower stat.]]):format(resistGain)
		end
	end,
}
