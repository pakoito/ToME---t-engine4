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
	name = "Physical Conditioning",
	type = {"technique/conditioning", 1},
	require = techs_con_req1,
	mode = "passive",
	points = 5,
	getArmor = function(self, t) return 4 + self:combatTalentStatDamage(t, "con", 1, 20) end,
	getPhysical = function(self, t) return 4 + self:combatTalentStatDamage(t, "con", 1, 20) end,
	info = function(self, t)
		local armor = t.getArmor(self, t)
		local saves = t.getPhysical(self, t)
		return ([[Physical conditioning that increases armor by %d and physical saves by %d.
		The bonuses will scale with your Constitution stat.]]):
		format(armor, saves)
	end,
}

newTalent{
	name = "Firm Footing",
	type = {"technique/conditioning", 2},
	require = techs_con_req2,
	mode = "passive",
	points = 5,
	getResists = function(self, t) return self:getTalentLevelRaw(t) * 15 end,
	on_learn = function(self, t)
		self:attr("knockback_immune", 0.15)
		self:attr("pin_immune", 0.15)
	end,
	on_unlearn = function(self, t)
		self:attr("knockback_immune", -0.15)
		self:attr("pin_immune", -0.15)
	end,
	info = function(self, t)
		local resists = t.getResists(self, t)
		return ([[Increases Knockback and Pin resistance by %d%%.]]):
		format(resists)
	end,
}

newTalent{
	name = "Iron Skin",
	type = {"technique/conditioning", 3},
	require = techs_con_req3,
	mode = "passive",
	points = 5,
	getPercent = function (self, t) return self:getTalentLevel(t) * 20 end,
	on_learn = function(self, t)
		self:updateConDamageReduction()
	end,
	on_unlearn = function(self, t)
		self:updateConDamageReduction()
	end,
	info = function(self, t)
		local percent = t.getPercent(self, t)
		return ([[You've learned to shrug off more damage then is normal.  Increases your effective constitution  for resist all bonuses by %d%%.]]):
		format(percent)
	end,
}

newTalent{
	name = "Unflinching Resolve",
	type = {"technique/conditioning", 4},
	require = techs_con_req4,
	mode = "passive",
	points = 5,
	getRegen = function(self, t) return self:getTalentLevel(t) * 0.05 end,
	getResist = function(self, t) return self:getTalentLevelRaw(t) * 15 end,
	on_hit = function(self, t, dam)
		local power = (dam * t.getRegen(self, t)) / 3
		self:setEffect(self.EFF_RECOVERY, 3, {power = power})
	end,
	on_learn = function(self, t)
		self:attr("stun_immune", 0.15)
	end,
	on_unlearn = function(self, t)
		self:attr("stun_immune", -0.15)
	end,
	info = function(self, t)
		local resist = t.getResist(self, t)
		local regen = t.getRegen(self, t)
		return ([[After being hit for 10%% or more of your maximum life in a single blow you recover %d%% of the damage over three turns.  Additionally your stun immunity is increased by %d%%.]]):
		format(regen * 100, resist)
	end,
}
