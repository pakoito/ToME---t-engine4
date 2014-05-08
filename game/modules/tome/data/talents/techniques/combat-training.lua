-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	getRes = function(self, t) return self:combatTalentScale(t, 4, 15, 0.75, 0, 0, true) end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "resists", {all = t.getRes(self, t)})
	end,
	info = function(self, t)
		local res = t.getRes(self, t)
		return ([[Your skin becomes more resilient to damage. Increases resistance to all damage by %0.1f%%.]]):
		format(res)
	end,
}

newTalent{
	name = "Armour Training",
	type = {"technique/combat-training", 1},
	mode = "passive",
	no_unlearn_last = true,
	points = 5,
	require = {stat = {str = function(level) return 16 + (level + 2) * (level - 1) end}},
	ArmorEffect = function(self, t)  -- Becomes more effective with heavier armors
		local am = self:getInven("BODY")[1] or {}
--		if am.subtype == "cloth" then return 0.75
--		elseif am.subtype == "light" then return 1.0
		if am.subtype == "cloth" then return 0
		elseif am.subtype == "light" then return 0
		elseif am.subtype == "heavy" then return 1.5
		elseif am.subtype == "massive" then	return 2.0
		end
		return 0
	end,
	-- Called by _M:combatArmor in mod.class.interface.Combat.lua
	getArmor = function(self, t)  return self:getTalentLevel(t) * t.ArmorEffect(self, t) * 1.4 end,
	-- Called by _M:combatArmorHardiness in mod.class.interface.Combat.lua
	getArmorHardiness = function(self, t) -- Matches previous progression for "heavy" armor
		return math.max(0, self:combatLimit(self:getTalentLevel(t) * 5 * t.ArmorEffect(self, t), 100, 5, 3.75, 50, 37.5))
	end,
	getCriticalChanceReduction = function(self, t) -- Matches previous progression for "heavy" armor
		return math.max(0, self:combatScale(self:getTalentLevel(t) * 3.8 * (t.ArmorEffect(self, t)/2)^0.5, 3.8, 3.3, 19, 16.45, 0.75))
	end,
	on_unlearn = function(self, t)
		for inven_id, inven in pairs(self.inven) do if inven.worn then
			for i = #inven, 1, -1 do
				local o = inven[i]
				local ok, err = self:canWearObject(o)
				if not ok and err == "missing dependency" then
					game.logPlayer(self, "You cannot use your %s anymore.", o:getName{do_color=true})
					local o = self:removeObject(inven, i, true)
					self:addObject(self.INVEN_INVEN, o)
					self:sortInven()
				end
			end
		end end
	end,
--	getArmorHardiness = function(self, t) return self:getTalentLevel(t) * 10 end,
--	getArmor = function(self, t) return self:getTalentLevel(t) * 2.8 end,
--	getCriticalChanceReduction = function(self, t) return self:getTalentLevel(t) * 3.8 end,
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
		return ([[You become better at using your armour to deflect blows and protect your vital areas. Increases Armour value by %d, Armour hardiness by %d%%, and reduces chance to be critically hit by %d%% with your current body armour.
		(This talent only provides bonuses for heavy mail or massive plate armour.)
		At level 1, it allows you to wear heavy mail armour, gauntlets, helms, and heavy boots.
		At level 2, it allows you to wear shields.
		At level 3, it allows you to wear massive plate armour.
		%s]]):format(armor, hardiness, criticalreduction, classrestriction)
	end,
}

newTalent{
	name = "Combat Accuracy", short_name = "WEAPON_COMBAT",
	type = {"technique/combat-training", 1},
	points = 5,
	levelup_screen_break_line = true,
	require = { level=function(level) return (level - 1) * 4 end },
	mode = "passive",
	--getAttack = function(self, t) return self:getTalentLevel(t) * 10 end,
	getAttack = function(self, t) return self:combatTalentScale(t, 10, 50) end, -- match values at 1 and 5 for old formula
	info = function(self, t)
		local attack = t.getAttack(self, t)
		return ([[Increases the accuracy of unarmed, melee and ranged weapons by %d.]]):
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
		return ([[Increases Physical Power by %d, and increases weapon damage by %d%% when using swords, axes or maces.]]):
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
		return ([[Increases Physical Power by %d, and increases weapon damage by %d%% when using daggers.]]):
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
		return ([[Increases Physical Power by %d, and increases weapon damage by %d%% when using exotic weapons.]]):
		format(damage, 100*inc)
	end,
}
