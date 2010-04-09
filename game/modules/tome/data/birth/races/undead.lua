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
--                       Ghouls                        --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Undead",
	desc = {
		"Undeads are humanoids (humans, elves, dwarves, ...) that have been brought back to life by the corruption of dark magics.",
		"Undead can take many forms from ghouls to vampires and liches.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "never",
			Ghoul = function() return config.settings.tome.allow_build.undead_ghoul and "allow" or "never" end,
		},
	},
}

newBirthDescriptor
{
	type = "subrace",
	name = "Ghoul",
	desc = {
		"Ghouls are dumb but resilient rotting undead creatures, making good fighters.",
		"They have access to special ghoul talents and a wide range of undead abilities:",
		"- great poison resistance",
		"- bleeding immunity",
		"- stun resistance",
		"- fear immunity",
		"The rotting body of ghouls also forces them to act a bit slower than most creatures.",
	},
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "never",
			Male = "allow",
		},
	},
	stats = { str=3, con=5, wil=-2, mag=0, dex=1, cun=2 },
	talents_types = {
		["undead/ghoul"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_GHOUL]=1,
	},
	copy = {
		type = "undead", subtype="ghoul",
		default_wilderness = {"wilderness/main", 39, 17},
		starting_zone = "tower-amon-sul",
		starting_quest = "start-dunadan",
		starting_intro = "dwarf",
		life_rating=14,
		poison_immune = 0.8,
		cut_immune = 1,
		stun_immune = 0.5,
		fear_immune = 1,
		energy = {mod=0.8},
	},
	experience = 2,
}
