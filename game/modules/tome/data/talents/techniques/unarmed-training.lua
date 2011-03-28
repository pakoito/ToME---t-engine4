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

-- Empty Hand adds extra scaling to gauntlet and glove attacks based on character level.

newTalent{
	name = "Empty Hand",
	type = {"technique/unarmed-other", 1},
	innate = true,
	hide = true,
	mode = "passive",
	points = 1,
	getDamage = function(self, t) return self.level * 0.5 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Adds %d damage to all glove and gauntlet strikes.
		This talent's effects will scale with your level.]]):
		format(damage)
	end,
}

-- generic unarmed training

newTalent{
	name = "Unarmed Mastery",
	type = {"technique/unarmed-training", 1},
	points = 10,
	require = { stat = { dex=function(level) return 12 + level * 3 end }, },
	mode = "passive",
	getDamage = function(self, t) return math.sqrt(self:getTalentLevel(t) / 10) end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Increases damage done with unarmed attacks by %d%%.]]):
		format(100 * damage)
	end,
}

newTalent{
	name = "Steady Mind",
	type = {"technique/unarmed-training", 2},
	mode = "passive",
	points = 5,
	require = techs_dex_req2,
	getDefense = function(self, t) return 4 + self:combatTalentStatDamage(t, "dex", 1, 20) end,
	getMental = function(self, t) return 4 + self:combatTalentStatDamage(t, "cun", 1, 20) end,
	info = function(self, t)
		local defense = t.getDefense(self, t)
		local saves = t.getMental(self, t)
		return ([[Superior cunning and training allows you to out think and out wit your opponents physical and mental assualts.  Increases defense by %d and mental saves by %d.
		The defense bonus will scale with the Dexterity stat and the save bonus with the Cunning stat.]]):
		format(defense, saves)
	end,
}

newTalent{
	name = "Heightened Reflexes",
	type = {"technique/unarmed-training", 3},
	require = techs_dex_req3,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return 1 + math.floor(self:getTalentLevel(t)) end,
	do_reflexes = function(self, t)
		self:setEffect(self.EFF_REFLEXIVE_DODGING, t.getDuration(self, t), {power=1})
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[When you're targeted by a projectile your global speed is increased by 100%% for %d turns.  Taking any action other then movement will break the effect.]]):
		format(duration)
	end,
}

newTalent{
	name = "Combo String",
	type = {"technique/unarmed-training", 4},
	require = techs_dex_req4,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return math.floor(self:getTalentLevel(t)/2) end,
	getChance = function(self, t) return self:getTalentLevel(t) * (5 + self:getCun(5)) end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[When building a combo point you have a %d%% chance to gain an extra combo point.  Additionally your combo points will last %d turns longer before expiring.
		The chance of building a second combo point will improve with the cunning stat.]]):
		format(chance, duration)
	end,
}