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

---------------------------------------------------------
--                       Orcs                       --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Orc",
	desc = {
		"Since their creation by Morgoth the Orcs have been the pawns of the forces of darkness.",
		"While both Sauron and Morgoth were destroy, the orcs survived and found a new master in the Far East.",
		"Orcs are a ruthless warriors, yet they are not dumb and some are terribly cunning.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			["Uruk-hai"] = "allow",
		},
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
		class =
		{
			Mage = "disallow",
		},
	},
	stats = { str=4, con=1, wil=2, mag=-2, dex=-2 },
	talents = {
		[ActorTalents.T_ORC_FURY]=1,
	},
	copy = {
		faction = "orc-pride",
		type = "humanoid", subtype="orc",
		default_wilderness = {10, 39, "wilderness-arda-fareast"},
		starting_zone = "wilderness-arda-fareast",
		starting_quest = "start-dunadan",
		starting_intro = "orc",
		life_rating=12,
	},
	experience = 1.3,
}

--------------------------------------------------------
--                       Orcs                         --
--------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Uruk-hai",
	desc = {
		"",
	},
}
