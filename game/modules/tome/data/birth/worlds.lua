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

-- Player worlds
newBirthDescriptor{
	type = "world",
	name = "Arda",
	desc =
	{
		"Arda, the World.",
		"It was shaped into being ages ago by the Music of the Ainur.",
		"It is home of elves, men, dwarves and hobbits, but also evil orcs, trolls and dragons.",
		"Since the downfall of Sauron, the lands have known relative peace.",
		"Until recently it was the only world known to exist.",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "never",
			Human = "allow",
			Elf = "allow",
			Dwarf = "allow",
			Hobbit = "allow",
--			Orc = function() return config.settings.tome.allow_build.evil and "allow" or "never" end,
--			Troll = function() return config.settings.tome.allow_build.evil and "allow" or "never" end,
			Undead = function() return config.settings.tome.allow_build.undead and "allow" or "never" end,
		},

		class =
		{
			__ALL__ = "allow",
			Mage = function() return config.settings.tome.allow_build.mage and "allow" or "never" end,
			Wilder = function() return (
				config.settings.tome.allow_build.wilder_summoner or
				config.settings.tome.allow_build.wilder_wyrmic
				) and "allow" or "never"
			end,
		},
	},
}

newBirthDescriptor{
	type = "world",
	name = "Spydrë",
	desc =
	{
		"Spydrë is home to the essence of spiders. The mighty Ungoliant of Arda actually originating from this world.",
		"It is home to uncounted numbers of spider races, all fighting for supremacy of all the lands.",
		"Some humanoids also live there, but they are usually the prey, not the hunter.",
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "never",
			Human = "allow",
--			Spider = function() return config.settings.tome.allow_build.spider and "allow" or "never" end,
		},
	},
}
