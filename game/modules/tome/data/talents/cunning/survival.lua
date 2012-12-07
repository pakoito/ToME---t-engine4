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
	name = "Heightened Senses",
	type = {"cunning/survival", 1},
	require = cuns_req1,
	mode = "passive",
	points = 5,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "heightened_senses", 4 + math.ceil(self:getTalentLevel(t)))
	end,
	info = function(self, t)
		return ([[You notice the small things others do not notice, allowing you to "see" creatures in a %d radius even outside of light radius.
		This is not telepathy though, and is still limited to line of sight.
		Also, your attention to detail allows you to detect traps around you (%d detection 'power').
		At level 3 you learn to disarm known traps (%d disarm 'power').]]):
		format(4 + math.ceil(self:getTalentLevel(t)), self:getTalentLevel(t) * self:getCun(25, true), self:getTalentLevel(t) * self:getCun(25, true))
	end,
}

newTalent{
	name = "Charm Mastery",
	type = {"cunning/survival", 2},
	require = cuns_req2,
	mode = "passive",
	points = 5,
	cdReduc = function(tl) 
		if tl <=0 then return 0 end
		return math.floor(100*tl/(tl+7.5)) --I5 Limit < 100%
	end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "use_object_cooldown_reduce", t.cdReduc(self:getTalentLevel(t))) --I5
	end,
	on_unlearn = function(self, t)
	end,
	info = function(self, t)
		return ([[Your cunning allows you to use charms (wands, totems and torques) more efficiently, reducing their cooldowns by %d%%.]]):
		format(t.cdReduc(self:getTalentLevel(t))) --I5
	end,
}

newTalent{
	name = "Piercing Sight",
	type = {"cunning/survival", 3},
	require = cuns_req3,
	mode = "passive",
	points = 5,
	info = function(self, t)
		return ([[You look at your surroundings with more intensity than most people, allowing you to see stealthed or invisible creatures.
		Increases stealth detection by %d and invisibility detection by %d.
		The detection power increases with Cunning.]]):
		format(5 + self:getTalentLevel(t) * self:getCun(15, true), 5 + self:getTalentLevel(t) * self:getCun(15, true))
	end,
}

newTalent{
	name = "Evasion",
	type = {"cunning/survival", 4},
	points = 5,
	require = cuns_req4,
	random_ego = "defensive",
	tactical = { ESCAPE = 2, DEFEND = 2 },
	cooldown = 30,
	action = function(self, t)
		local dur = 5 + self:getWil(10)
		local chance = 5 * self:getTalentLevel(t) + self:getCun(25, true) + self:getDex(25, true)
		self:setEffect(self.EFF_EVASION, dur, {chance=chance})
		return true
	end,
	info = function(self, t)
		return ([[Your quick wit allows you to see attacks before they come, granting you a %d%% chance to completely evade them for %d turns.
		Duration increases with Willpower, and chance to evade with Cunning and Dexterity.]]):format(5 * self:getTalentLevel(t) + self:getCun(25, true) + self:getDex(25, true), 5 + self:getWil(10))
	end,
}
