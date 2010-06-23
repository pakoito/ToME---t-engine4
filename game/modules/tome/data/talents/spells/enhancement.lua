-- ToME - Tales of Middle-Earth
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
	name = "Fiery Hands",
	type = {"spell/enhancement",1},
	require = spells_req1,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 40,
	tactical = {
		ATTACK = 10,
	},
	activate = function(self, t)
		game:playSoundNear(self, "talents/fire")
		return {
			dam = self:addTemporaryValue("melee_project", {[DamageType.FIRE] = self:combatTalentSpellDamage(t, 5, 20)}),
			per = self:addTemporaryValue("inc_damage", {[DamageType.FIRE] = self:combatTalentSpellDamage(t, 5, 14)}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("melee_project", p.dam)
		self:removeTemporaryValue("inc_damage", p.per)
		return true
	end,
	info = function(self, t)
		return ([[Engulfs your hands (and weapons) in a sheath of fire, dealing %d fire damage per melee attack and increasing all fire damage by %d%%.]]):
		format(self:combatTalentSpellDamage(t, 5, 20), self:combatTalentSpellDamage(t, 5, 14))
	end,
}

newTalent{
	name = "Earthen Barrier",
	type = {"spell/enhancement", 2},
	points = 5,
	cooldown = 25,
	mana = 45,
	require = spells_req2,
	range = 20,
	action = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		self:setEffect(self.EFF_EARTHEN_BARRIER, 10, {power=self:combatTalentSpellDamage(t, 10, 60)})
		return true
	end,
	info = function(self, t)
		return ([[Hardens your skin with the power of earth, reducing physical damage taken by %d%%.]]):format(self:combatTalentSpellDamage(t, 10, 60))
	end,
}

newTalent{
	name = "Frost Hands",
	type = {"spell/enhancement", 3},
	require = spells_req3,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 40,
	tactical = {
		ATTACK = 10,
	},
	activate = function(self, t)
		game:playSoundNear(self, "talents/ice")
		return {
			dam = self:addTemporaryValue("melee_project", {[DamageType.ICE] = self:combatTalentSpellDamage(t, 3, 15)}),
			per = self:addTemporaryValue("inc_damage", {[DamageType.COLD] = self:combatTalentSpellDamage(t, 5, 14)}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("melee_project", p.dam)
		self:removeTemporaryValue("inc_damage", p.per)
		return true
	end,
	info = function(self, t)
		return ([[Engulfs your hands (and weapons) in a sheath of ice, dealing %d ice damage per melee attack and increasing all cold damage by %d%%.]]):
		format(self:combatTalentSpellDamage(t, 3, 15), self:combatTalentSpellDamage(t, 5, 14))
	end,
}

newTalent{
	name = "Inner Power",
	type = {"spell/enhancement", 4},
	require = spells_req4,
	points = 5,
	mode = "sustained",
	cooldown = 10,
	sustain_mana = 75,
	tactical = {
		DEFEND = 10,
	},
	activate = function(self, t)
		game:playSoundNear(self, "talents/spell_generic")
		local power = math.floor(self:combatTalentSpellDamage(t, 2, 18))
		return {
			stats = self:addTemporaryValue("inc_stats", {
				[self.STAT_STR] = power,
				[self.STAT_DEX] = power,
				[self.STAT_MAG] = power,
				[self.STAT_WIL] = power,
				[self.STAT_CUN] = power,
				[self.STAT_CON] = power,
			}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("inc_stats", p.stats)
		return true
	end,
	info = function(self, t)
		return ([[You concentrate on your inner self, increasing your stats each by %d.]]):
		format(self:combatTalentSpellDamage(t, 2, 18))
	end,
}
