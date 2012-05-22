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

---------------------------------------------------------
--                      Constructs                     --
---------------------------------------------------------
newBirthDescriptor{
	type = "race",
	name = "Construct",
	locked = function() return profile.mod.allow_build.construct and true or "hide" end,
	locked_desc = "",
	desc = {
		"Constructs are not natural creatures.",
		"The most usual contructs are golems, but they can vary in shape, form and abilities.",
	},
	descriptor_choices =
	{
		subrace =
		{
			__ALL__ = "disallow",
			["Runic Golem"] = "allow",
		},
	},
	random_escort_possibilities = { {"trollmire", 2, 3}, {"ruins-kor-pul", 1, 2}, {"daikara", 1, 2}, {"old-forest", 1, 4}, {"dreadfell", 1, 8}, {"reknor", 1, 2}, },
}

newBirthDescriptor
{
	type = "subrace",
	name = "Runic Golem",
	locked = function() return profile.mod.allow_build.construct_runic_golem and true or "hide" end,
	locked_desc = "",
	desc = {
		"Runic Golems are creatures made of solid rock and animated using arcane forces.",
		"They cannot be of any class, but they have many intrinsic abilities.",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +3 Strength, -2 Dexterity, +3 Constitution",
		"#LIGHT_BLUE# * +2 Magic, +2 Willpower, -5 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# 13",
		"#GOLD#Experience penalty:#LIGHT_BLUE# 50%",
	},
	descriptor_choices =
	{
		sex =
		{
			__ALL__ = "disallow",
			Male = "allow",
		},
		class =
		{
			__ALL__ = "disallow",
			None = "allow",
		},
		subclass =
		{
			__ALL__ = "disallow",
		},
	},
	inc_stats = { str=3, con=3, wil=2, mag=2, dex=-2, cun=-5 },
	talents_types = {
		["golem/arcane"]={true, 0.3},
		["golem/fighting"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_MANA_POOL]=1,
		[ActorTalents.T_STAMINA_POOL]=1,
	},
	copy = {
		resolvers.generic(function(e) e.descriptor.class = "Golem" e.descriptor.subclass = "Golem" end),
		resolvers.genericlast(function(e) e.faction = "undead" end),
		default_wilderness = {"playerpop", "allied"},
		starting_zone = "ruins-kor-pul",
		starting_quest = "start-allied",
		blood_color = colors.GREY,
		resolvers.inventory{ id=true, {defined="ORB_SCRYING"} },
		resolvers.generic(function(e) e.hotkey[10] = {"inventory", "Orb of Scrying"} end),

		mana_regen = 0.5,
		mana_rating = 7,
		inscription_restrictions = { ["inscriptions/runes"] = true, },
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=25, dur=10, mana=620}),
		resolvers.inscription("RUNE:_SHIELDING", {cooldown=14, dur=5, power=100}),
		resolvers.inscription("RUNE:_PHASE_DOOR", {cooldown=7, range=10}),

		type = "construct", subtype="golem", image = "npc/alchemist_golem.png",
		starting_intro = "ghoul",
		life_rating=13,
		poison_immune = 1,
		cut_immune = 1,
		stun_immune = 1,
		fear_immune = 1,
		construct = 1,

		moddable_tile = "runic_golem",
		moddable_tile_nude = true,
	},
	experience = 1.5,
}
