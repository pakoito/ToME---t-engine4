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

-- Empty Hand adds extra scaling to gauntlet and glove attacks based on character level.

newTalent{
	name = "Empty Hand",
	type = {"technique/unarmed-other", 1},
	innate = true,
	hide = true,
	mode = "passive",
	points = 1,
	no_unlearn_last = true,
	getDamage = function(self, t) return self.level * 0.5 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Grants %d physical power when fightning unarmed (or with gloves or gauntlets).
		This talent's effects will scale with your level.]]):
		format(damage)
	end,
}

-- generic unarmed training
newTalent{
	name = "Unarmed Mastery",
	type = {"technique/unarmed-training", 1},
	points = 5,
	require = { stat = { cun=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Increases damage done with all unarmed attacks by %d%% (including grapples and kicks).  Also increases Physical Power by %d.
		Note that brawlers naturally gain 0.5 physical power per character level while unarmed (current brawler physical power bonus: %0.1f) and attack 40%% faster while unarmed.]]):
		format(100*inc, damage, self.level * 0.5)
	end,
}

newTalent{
	name = "Steady Mind",
	type = {"technique/unarmed-training", 2},
	mode = "passive",
	points = 5,
	require = techs_cun_req2,
	getDefense = function(self, t) return self:combatTalentStatDamage(t, "cun", 5, 35) end,
	getMental = function(self, t) return self:combatTalentStatDamage(t, "cun", 5, 35) end,
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
	require = techs_cun_req3,
	mode = "passive",
	points = 5,
	getPower = function(self, t) return self:getTalentLevel(t)/2 end,
	do_reflexes = function(self, t)
		self:setEffect(self.EFF_REFLEXIVE_DODGING, 1, {power=t.getPower(self, t)})
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[When you're targeted by a projectile your global speed is increased by %d%% for 1 turn.  Taking any action other then movement will break the effect.]]):
		format(power * 100)
	end,
}

newTalent{
	name = "Combo String",
	type = {"technique/unarmed-training", 4},
	require = techs_cun_req4,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return math.ceil(self:getTalentLevel(t)/2) end,
	getChance = function(self, t) return self:getTalentLevel(t) * (5 + self:getCun(5, true)) end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local chance = t.getChance(self, t)
		return ([[When building a combo point you have a %d%% chance to gain an extra combo point.  Additionally your combo points will last %d turns longer before expiring.
		The chance of building a second combo point will improve with the cunning stat.]]):
		format(chance, duration)
	end,
}
