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
	name = "Stealth",
	type = {"cunning/stealth", 1},
	require = cuns_req1,
	mode = "sustained", no_sustain_autoreset = true,
	points = 5,
	cooldown = 10,
	getStealthPower = function(self, t) return 4 + self:getCun(10) * self:getTalentLevel(t) end,
	getRadius = function(self, t) return math.floor(10 - self:getTalentLevel(t) * 1.1) end,
	activate = function(self, t)
		local armor = self:getInven("BODY")[1]
		if armor and (armor.subtype == "heavy" or armor.subtype == "massive") then
			game.logPlayer(self, "You cannot Stealth with such heavy armour!")
			return nil
		end

		-- Check nearby actors
		local grids = core.fov.circle_grids(self.x, self.y, t.getRadius(self, t), true)
		for x, yy in pairs(grids) do for y in pairs(yy) do
			local actor = game.level.map(x, y, game.level.map.ACTOR)
			if actor and actor ~= self and actor:reactionToward(self) < 0 and not rng.percent(self.hide_chance or 0) then
				game.logPlayer(self, "You cannot Stealth with nearby foes watching!")
				return nil
			end
		end end

		local res = {
			stealth = self:addTemporaryValue("stealth", t.getStealthPower(self, t)),
			lite = self:addTemporaryValue("lite", -1000),
			infra = self:addTemporaryValue("infravision", 1),
		}
		game.level.map:updateMap(self.x, self.y)
		return res
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("stealth", p.stealth)
		self:removeTemporaryValue("infravision", p.infra)
		self:removeTemporaryValue("lite", p.lite)
		game.level.map:updateMap(self.x, self.y)
		return true
	end,
	info = function(self, t)
		local stealthpower = t.getStealthPower(self, t)
		local radius = t.getRadius(self, t)
		return ([[Enters stealth mode(with efficency of %d), making you harder to detect.
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
	getMultiplier = function(self, t) return 1.5 + self:getTalentLevel(t) / 7 end,
	info = function(self, t)
		local multiplier = t.getMultiplier(self, t)
		return ([[When striking from stealth, hits are automatically criticals if the target does not notice you.
		Shadowstrikes do %.02f%% damage versus a normal hit.]]):
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
	getChance = function(self, t) return 40 + self:getTalentLevel(t) * 7 end,
	action = function(self, t)
		if self:isTalentActive(self.T_STEALTH) then return end

		self.talents_cd[self.T_STEALTH] = nil
		self.changed = true
		self.hide_chance = t.getChance(self, t)
		self:useTalent(self.T_STEALTH)
		self.hide_chance = nil
		return true
	end,
	info = function(self, t)
		local chance = t.getChance(self, t)
		return ([[You have learned how to be stealthly even when in plain sight of your foes, with a %d%% chance of success. This also resets the cooldown of your stealth talent.]]):
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
