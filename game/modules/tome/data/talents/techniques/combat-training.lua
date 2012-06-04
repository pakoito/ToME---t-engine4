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
	name = "Thick Skin",
	type = {"technique/combat-training", 1},
	mode = "passive",
	points = 5,
	require = { stat = { con=function(level) return 14 + level * 9 end }, },
	getRes = function(self, t) return 3 * self:getTalentLevelRaw(t) end,
	on_learn = function(self, t)
		self.resists.all = (self.resists.all or 0) + 3
	end,
	on_unlearn = function(self, t)
		self.resists.all = (self.resists.all or 0) - 3
	end,
	info = function(self, t)
		local res = t.getRes(self, t)
		return ([[Your skin becomes more resilient to damage. Increases resistance to all damage by %d%%]]):
		format(res)
	end,
}

newTalent{
	name = "Armour Training",
	type = {"technique/combat-training", 1},
	mode = "passive",
	points = 10,
	require = { stat = { str=function(level) return 18 + level - 1 end }, },
	on_unlearn = function(self, t)
		for inven_id, inven in pairs(self.inven) do if inven.worn then
			for i = #inven, 1, -1 do
				local o = inven[i]
				local ok, err = self:canWearObject(o)
				if not ok and err == "missing dependency" then
					game.logPlayer(self, "You can not use your %s anymore.", o:getName{do_color=true})
					local o = self:removeObject(inven, i, true)
					self:addObject(self.INVEN_INVEN, o)
					self:sortInven()
				end
			end
		end end
	end,
	getArmorHardiness = function(self, t) return self:getTalentLevel(t) * 5 end,
	getArmor = function(self, t) return self:getTalentLevel(t) * 1.4 end,
	getCriticalChanceReduction = function(self, t) return self:getTalentLevel(t) * 1.9 end,
	info = function(self, t)
		local hardiness = t.getArmorHardiness(self, t)
		local armor = t.getArmor(self, t)
		local criticalreduction = t.getCriticalChanceReduction(self, t)
		local classrestriction = ""
		if self.descriptor and self.descriptor.subclass == "Brawler" then
			classrestriction = "(Note that brawlers will be unable to perform many of their talents in massive armour.)"
		end
		if self:knowTalent(self.T_STEALTH) then
			classrestriction = "(Note that wearing mail or plate armour will interfere with stealth.)"
		end
		return ([[Teaches the usage of armours. Increases armour value by %d and reduces chance to be critically hit by %d%% when wearing a heavy mail armour or a massive plate armour.
		It also increases armour hardiness by %d%%.
		At level 1 it allows you to wear gauntlets, helms and heavy boots.
		At level 2 it allows you to wear heavy mail armour.
		At level 3 it allows you to wear shields.
		At level 4 it allows you to wear massive plate armour.
		%s]]):
		format(armor, criticalreduction, hardiness, classrestriction)
	end,
}

newTalent{
	name = "Combat Accuracy", short_name = "WEAPON_COMBAT",
	type = {"technique/combat-training", 1},
	points = 5,
	require = { level=function(level) return (level - 1) * 4 end },
	mode = "passive",
	getAttack = function(self, t) return self:getTalentLevel(t) * 10 end,
	info = function(self, t)
		local attack = t.getAttack(self, t)
		return ([[Increases accuracy of unarmed, melee and ranged weapons by %d.]]):
		format(attack)
	end,
}

newTalent{
	name = "Weapons Mastery",
	type = {"technique/combat-training", 1},
	points = 5,
	require = { stat = { str=function(level) return 12 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Increases Physical Power by %d. Also increases damage done with swords, axes, maces by %d%%]]):
		format(damage, 100*inc)
	end,
}


newTalent{
	name = "Dagger Mastery", short_name = "KNIFE_MASTERY",
	type = {"technique/combat-training", 1},
	points = 5,
	require = { stat = { dex=function(level) return 10 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Increases Physical Power by %d. Also increases damage done with daggers by %d%%]]):
		format(damage, 100*inc)
	end,
}

newTalent{
	name = "Exotic Weapons Mastery",
	type = {"technique/combat-training", 1},
	hide = true,
	points = 5,
	require = { stat = { str=function(level) return 10 + level * 6 end, dex=function(level) return 10 + level * 6 end }, },
	mode = "passive",
	getDamage = function(self, t) return self:getTalentLevel(t) * 10 end,
	getPercentInc = function(self, t) return math.sqrt(self:getTalentLevel(t) / 5) / 2 end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local inc = t.getPercentInc(self, t)
		return ([[Increases Physical Power by %d. Also increases damage done with exotic weapons by %d%%]]):
		format(damage, 100*inc)
	end,
}
