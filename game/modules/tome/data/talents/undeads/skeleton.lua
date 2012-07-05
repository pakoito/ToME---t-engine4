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
	name = "Skeleton",
	type = {"undead/skeleton", 1},
	mode = "passive",
	require = undeads_req1,
	points = 5,
	on_learn = function(self, t)
		self.inc_stats[self.STAT_STR] = self.inc_stats[self.STAT_STR] + 2
		self:onStatChange(self.STAT_STR, 2)
		self.inc_stats[self.STAT_DEX] = self.inc_stats[self.STAT_DEX] + 2
		self:onStatChange(self.STAT_DEX, 2)
	end,
	on_unlearn = function(self, t)
		self.inc_stats[self.STAT_STR] = self.inc_stats[self.STAT_STR] - 2
		self:onStatChange(self.STAT_STR, -2)
		self.inc_stats[self.STAT_DEX] = self.inc_stats[self.STAT_DEX] - 2
		self:onStatChange(self.STAT_DEX, -2)
	end,
	info = function(self, t)
		return ([[Improves your skeletal condition, increasing strength and dexterity by %d.]]):format(2 * self:getTalentLevelRaw(t))
	end,
}

newTalent{
	name = "Bone Armour",
	type = {"undead/skeleton", 2},
	require = undeads_req2,
	points = 5,
	cooldown = 30,
	tactical = { DEFEND = 2 },
	action = function(self, t)
		self:setEffect(self.EFF_DAMAGE_SHIELD, 10, {power=50 + 70 * self:getTalentLevel(t) + self:getDex(350, true)})
		return true
	end,
	info = function(self, t)
		return ([[Creates a shield of bones absorbing %d damage. Lasts for 10 turns.
		The damage absorbed increases with dexterity.]]):
		format(50 + 70 * self:getTalentLevel(t) + self:getDex(350, true))
	end,
}

newTalent{
	name = "Resilient Bones",
	type = {"undead/skeleton", 3},
	require = undeads_req3,
	points = 5,
	mode = "passive",
	range = 1,
	info = function(self, t)
		return ([[Your undead bones are very resilient, reducing the duration of all detrimental effects on you by %d%%.]]):
		format(100 * (self:getTalentLevel(self.T_RESILIENT_BONES) / 12))
	end,
}

newTalent{ short_name = "SKELETON_REASSEMBLE",
	name = "Re-assemble",
	type = {"undead/skeleton",4},
	require = undeads_req4,
	points = 5,
	cooldown = function(self, t) return 45 - self:getTalentLevelRaw(t) * 4 end,
	tactical = { HEAL = 2 },
	is_heal = true,
	on_learn = function(self, t)
		if self:getTalentLevelRaw(t) == 5 then
			self:attr("self_resurrect", 1)
		end
	end,
	on_unlearn = function(self, t)
		if self:getTalentLevelRaw(t) == 4 then
			self:attr("self_resurrect", -1)
		end
	end,
	action = function(self, t)
		self:attr("allow_on_heal", 1)
		self:heal(100 * self:getTalentLevel(t), self)
		self:attr("allow_on_heal", -1)
		game:playSoundNear(self, "talents/heal")
		return true
	end,
	info = function(self, t)
		return ([[Re-position some of your bones, healing yourself for %d.
		At level 5 you will gain the ability to completely re-assemble your body should it be destroyed (can only be used once)]]):
		format(100 * self:getTalentLevel(t))
	end,
}
