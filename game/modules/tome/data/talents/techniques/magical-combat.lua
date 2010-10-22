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
	name = "Arcane Combat",
	type = {"technique/magical-combat", 1},
	mode = "sustained",
	points = 5,
	require = techs_req1,
	sustain_stamina = 20,
	no_energy = true,
	cooldown = 5,
	activate = function(self, t)
		return {}
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		return ([[Allows one to use a melee weapon to focus spells, granting %d%% chance per melee attack to deliver a Flame, Flameshock, Lightning, or Chain Lightning spell as a free action on the target.
		Delivering the spell this way will not trigger a spell cooldown, but only works if the spell is not cooling-down.
		The chance increases with dexterity.]]):
		format(20 + self:getTalentLevel(t) * (1 + self:getDex(9, true)))
	end,
}

newTalent{
	name = "Arcane Dexterity",
	type = {"technique/magical-combat", 2},
	mode = "passive",
	points = 5,
	require = techs_req2,
	info = function(self, t)
		return ([[The user gains a bonus to spellpower equal to %d%% of their dexterity.]]):
		format(15 + self:getTalentLevel(t) * 5)
	end,
}

newTalent{
	name = "Arcane Feed",
	type = {"technique/magical-combat", 3},
	points = 5,
	cooldown = 5,
	stamina = 100,
	require = techs_req3,
	range = 20,
	action = function(self, t)
		self:incMana(40 + self:getTalentLevel(t) * 12)
		return true
	end,
	info = function(self, t)
		return ([[Regenerates %d mana at the cost of 100 stamina.]]):format(40 + self:getTalentLevel(t) * 12)
	end,
}

newTalent{
	name = "Arcane Destruction",
	type = {"technique/magical-combat", 4},
	mode = "passive",
	points = 5,
	require = techs_req4,
	info = function(self, t)
		return ([[Raw magical damage channels through the caster's weapon, increasing physical damage by %d.]]):
		format(self:combatSpellpower() * self:getTalentLevel(Talents.T_ARCANE_DESTRUCTION) / 9)
	end,
}
