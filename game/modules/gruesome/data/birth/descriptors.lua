-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

newBirthDescriptor{
	type = "base",
	name = "base",
	desc = {
	},

	copy = {
		type = "grue", subtype = "grue",
		display = "G", color = {r=0,g=0,b=0},
		max_life = 2,
		max_power = 2,
	},
	talents = {
		[ActorTalents.T_SHADOW_BALL] = 1,
		[ActorTalents.T_SHADOW_WALK] = 1,
		[ActorTalents.T_DARK_EYES] = 1,
	},
}
