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
			dam = self:addTemporaryValue("melee_project", {[DamageType.FIRE] = 5 + self:getTalentLevel(t) * self:combatSpellpower(0.08)}),
			per = self:addTemporaryValue("inc_damage", {[DamageType.FIRE] = 5 + self:getTalentLevel(t) * self:combatSpellpower(0.05)}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("melee_project", p.dam)
		self:removeTemporaryValue("inc_damage", p.per)
		return true
	end,
	info = function(self, t)
		return ([[Engulfs your hands (and weapons) in a sheath of fire, dealing %d fire damage per melee attacks and increasing all fire damage by %d%%.]]):
		format(5 + self:getTalentLevel(t) * self:combatSpellpower(0.08), 5 + self:getTalentLevel(t) * self:combatSpellpower(0.05))
	end,
}

newTalent{
	name = "Frost Hands",
	type = {"spell/enhancement",2},
	require = spells_req2,
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
			dam = self:addTemporaryValue("melee_project", {[DamageType.ICE] = 3 + self:getTalentLevel(t) * self:combatSpellpower(0.05)}),
			per = self:addTemporaryValue("inc_damage", {[DamageType.COLD] = 4 + self:getTalentLevel(t) * self:combatSpellpower(0.04)}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeTemporaryValue("melee_project", p.dam)
		self:removeTemporaryValue("inc_damage", p.per)
		return true
	end,
	info = function(self, t)
		return ([[Engulfs your hands (and weapons) in a sheath of ice, dealing %d ice damage per melee attacks and increasing all cold damage by %d%%.]]):
		format(3 + self:getTalentLevel(t) * self:combatSpellpower(0.05), 4 + self:getTalentLevel(t) * self:combatSpellpower(0.04))
	end,
}
