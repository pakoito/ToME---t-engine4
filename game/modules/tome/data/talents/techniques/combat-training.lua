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

newTalent{
	name = "Health",
	type = {"technique/combat-training", 1},
	mode = "passive",
	points = 5,
	require = { stat = { con=function(level) return 14 + level * 9 end }, },
	getHealth = function(self, t) return 40 * self:getTalentLevelRaw(t) end,
	on_learn = function(self, t)
		self.max_life = self.max_life + 40
	end,
	on_unlearn = function(self, t)
		self.max_life = self.max_life - 40
	end,
	info = function(self, t)
		local health = t.getHealth(self, t)
		return ([[Increases your maximum life by %d]]):
		format(health)
	end,
}

newTalent{
	name = "Armour Training",
	type = {"technique/combat-training", 1},
	mode = "passive",
	points = 10,
	require = { stat = { str=function(level) return 18 + level - 1 end }, },
	getArmorHardiness = function(self, t) return self:getTalentLevel(t) * 5 end,
	getArmor = function(self, t) return self:getTalentLevel(t) * 1.4 end,
	getCriticalChanceReduction = function(self, t) return self:getTalentLevel(t) * 1.9 end,
	info = function(self, t)
		local hardiness = t.getArmorHardiness(self, t)
		local armor = t.getArmor(self, t)
		local criticalreduction = t.getCriticalChanceReduction(self, t)
		return ([[Teaches the usage of armours. Increases armour value by %d and reduces chance to be critically hit by %d%% when wearing a heavy mail armour or a massive plate armour.
		It also increases armour hardiness by %d%%.
		At level 1 it allows you to wear gauntlets, helms and heavy boots.
		At level 2 it allows you to wear heavy mail armour.
		At level 3 it allows you to wear shields.
		At level 4 it allows you to wear massive plate armour.]]):
		format(armor, criticalreduction, hardiness)
	end,
}

newTalent{
	name = "Combat Accuracy", short_name = "WEAPON_COMBAT",
	type = {"technique/combat-training", 1},
	points = 10,
	require = { level=function(level) return (level - 1) * 2 end },
	mode = "passive",
	getAttack = function(self, t) return self:getTalentLevel(t) * 5 end,
	info = function(self, t)
		local attack = t.getAttack(self, t)
		return ([[Increases accuracy of unarmed, melee and ranged weapons by %d.]]):
		format(attack)
	end,
}

newTalent{
	name = "Weapons Mastery",
	type = {"technique/combat-training", 1},
	points = 10,
	require = { stat = { str=function(level) return 12 + level * 3 end }, },
	mode = "passive",
	getDamage = function(self, t) return math.sqrt(self:getTalentLevel(t) / 10) end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Increases damage done with swords, maces and axes by %d%%.]]):
		format(100 * damage)
	end,
}


newTalent{
	name = "Knife Mastery",
	type = {"technique/combat-training", 1},
	points = 10,
	require = { stat = { dex=function(level) return 10 + level * 3 end }, },
	mode = "passive",
	getDamage = function(self, t) return math.sqrt(self:getTalentLevel(t) / 10) end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Increases damage done with knives by %d%%.]]):
		format(100 * damage)
	end,
}

newTalent{
	name = "Exotic Weapons Mastery",
	type = {"technique/combat-training", 1},
	hide = true,
	points = 10,
	require = { stat = { str=function(level) return 10 + level * 3 end, dex=function(level) return 10 + level * 3 end }, },
	mode = "passive",
	getDamage = function(self, t) return math.sqrt(self:getTalentLevel(t) / 10) end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Increases damage done with exotic weapons (whips, tridents, ...) by %d%%.]]):
		format(100 * damage)
	end,
}
