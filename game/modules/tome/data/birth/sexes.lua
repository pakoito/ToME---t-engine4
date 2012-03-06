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

-- Player sexes
newBirthDescriptor{
	type = "sex",
	name = "Female",
	desc =
	{
		"You are a female of the species.",
		"There is no in-game difference between the two sexes.",
	},
	copy = { female=true, },
}

newBirthDescriptor{
	type = "sex",
	name = "Male",
	desc =
	{
		"You are a male of the species.",
		"There is no in-game difference between the two sexes.",
	},
	copy = { male=true, },
}
