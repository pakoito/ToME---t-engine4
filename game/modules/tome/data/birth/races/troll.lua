-- ToME - Tales of Maj'Eyal
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
--                       Trolls                       --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Troll",
	desc = {
		"",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			["Olog-hai"] = "allow",
		},
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
	},
	inc_stats = { str=4, con=3, wil=3, mag=-2, dex=-2 },
	talents = {
--		[ActorTalents.T_DWARF_RESILIENCE]=1,
	},
	copy = {
		faction = "orc-pride",
		type = "humanoid", subtype="troll",
		default_wilderness = {26, 7, "wilderness"},
		starting_zone = "trollmire",
		starting_quest = "start-dunadan",
		starting_intro = "dwarf",
		life_rating=10,
		resolvers.inscription("INFUSION:_REGENERATION", {cooldown=10, dur=5, heal=60}),
		resolvers.inscription("INFUSION:_WILD", {cooldown=12, what={poison=true}, dur=4, power=14}),
	},
	experience = 1.1,
}

---------------------------------------------------------
--                       Dwarves                       --
---------------------------------------------------------
newBirthDescriptor
{
	type = "subrace",
	name = "Olog-hai",
	desc = {
		"",
	},
}
