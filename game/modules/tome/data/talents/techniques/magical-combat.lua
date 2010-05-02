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
	mode = "passive",
	points = 5,
	require = techs_req1,
	info = function(self, t)
		return ([[Allows to use a melee weapon as a spell focus, granting %d%% chance per melee attacks to deliver a Flame, Flameshock, Lightning or Chain Lightning spell as a free action on their target.
		Delivering the spell this way will not trigger a spell cooldown but only works if the spell is not on cooldown.
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
		return ([[The user gains a bonus to spellpower equal to %d%% of her dexterity.]]):
		format(20 + self:getTalentLevel(t) * 7)
	end,
}
