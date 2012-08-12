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
	name = "Stealth",
	type = {"cunning/stealth", 1},
	require = cuns_req1,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	cooldown = 10,
	allow_autocast = true,
	no_energy = true,
	tactical = { BUFF = 3 },
	getStealthPower = function(self, t) return 4 + self:getCun(10, true) * self:getTalentLevel(t) end,
	getRadius = function(self, t) return math.max(0, math.floor(10 - self:getTalentLevel(t) * 1.1)) end,
	on_pre_use = function(self, t, silent)
		if self:isTalentActive(t.id) then return true end
		local armor = self:getInven("BODY") and self:getInven("BODY")[1]
		if armor and (armor.subtype == "heavy" or armor.subtype == "massive") then
			if not silent then game.logPlayer(self, "You cannot Stealth with such heavy armour!") end
			return nil
		end

		-- Check nearby actors
		if not self.x or not self.y or not game.level then return end
		local grids = core.fov.circle_grids(self.x, self.y, t.getRadius(self, t), true)
		for x, yy in pairs(grids) do for y in pairs(yy) do
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self and actor:reactionToward(self) < 0 and not rng.percent(self.hide_chance or 0) then
				if not silent then game.logPlayer(self, "You cannot Stealth with nearby foes watching!") end
				return nil
			end
		end end
		return true
	end,
	activate = function(self, t)
		local res = {
			stealth = self:addTemporaryValue("stealth", t.getStealthPower(self, t)),
			lite = self:addTemporaryValue("lite", -1000),
			infra = self:addTemporaryValue("infravision", 1),
		}
		self:resetCanSeeCacheOf()
		if self.updateMainShader then self:updateMainShader() end
		return res
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("stealth", p.stealth)
		self:removeTemporaryValue("infravision", p.infra)
		self:removeTemporaryValue("lite", p.lite)
		self:resetCanSeeCacheOf()
		if self.updateMainShader then self:updateMainShader() end
		return true
	end,
	info = function(self, t)
		local stealthpower = t.getStealthPower(self, t) + (self:attr("inc_stealth") or 0)
		local radius = t.getRadius(self, t)
		return ([[Enters stealth mode (with efficiency of %d), making you harder to detect.
		The efficiency increases with Cunning.
		Stealth cannot work with heavy or massive armours.
		While in stealth mode, light radius is reduced to 0.
		There must be no foes in sight in a radius of %d around you to enter stealth.]]):
		format(stealthpower, radius)
	end,
}

newTalent{
	name = "Shadowstrike",
	type = {"cunning/stealth", 2},
	require = cuns_req2,
	mode = "passive",
	points = 5,
	getMultiplier = function(self, t) return self:getTalentLevel(t) / 7 end,
	info = function(self, t)
		local multiplier = t.getMultiplier(self, t)
		return ([[When striking from stealth, hits are automatically criticals if the target does not notice you.
		Shadowstrikes do +%.02f%% damage versus a normal critical hit.]]):
		format(multiplier * 100)
	end,
}

newTalent{
	name = "Hide in Plain Sight",
	type = {"cunning/stealth",3},
	require = cuns_req3,
	no_energy = "fake",
	points = 5,
	stamina = 20,
	cooldown = 40,
	tactical = { DEFEND = 2 },
	getChance = function(self, t) return 40 + self:getTalentLevel(t) * 7 end,
	action = function(self, t)
		if self:isTalentActive(self.T_STEALTH) then return end

		self.talents_cd[self.T_STEALTH] = nil
		self.changed = true
		self.hide_chance = t.getChance(self, t)
		self:useTalent(self.T_STEALTH)
		self.hide_chance = nil

		for uid, e in pairs(game.level.entities) do
			if e.ai_target and e.ai_target.actor == self then e:setTarget(nil) end
		end

		return true
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[You have learned how to be stealthy even when in plain sight of your foes, with a %d%% chance of success. This also resets the cooldown of your stealth talent.
		All creatures currently following you will loose all track.]]):
		format(chance)
	end,
}

newTalent{
	name = "Unseen Actions",
	type = {"cunning/stealth", 4},
	require = cuns_req4,
	mode = "passive",
	points = 5,
	getChance = function(self, t) return 10 + self:getTalentLevel(t) * 9 end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[When you perform an action from stealth (attacking, using objects, ...) you have a %d%% chance to not break stealth.]]):
		format(chance)
	end,
}
