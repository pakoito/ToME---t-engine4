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

newBirthDescriptor{
	type = "class",
	name = "Afflicted",
	locked = function() return profile.mod.allow_build.afflicted end,
	locked_desc = "Some walk in shadow, alone, unloved, unwanted. What powers they wield may be mighty, but their names are forever cursed.",
	desc = {
		"Afflicted classes have been twisted by their association with evil forces.",
		"They can use these forces to their advantage, but at a cost...",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Cursed = "allow",
			Doomed = "allow",
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Cursed",
	locked = function() return profile.mod.allow_build.afflicted_cursed end,
	locked_desc = "Affliction can run to the soul, and hatred can fill one's entire being. Overcome someone else's hated curse to know its dreaded meaning.",
	desc = {
		"Through ignorance, greed or folly the Cursed served some dark design and are now doomed to pay for their sins.",
		"Their only master now is the hatred they carry for every living thing.",
		"Drawing strength from the death of all they encounter, the Cursed become terrifying combatants.",
		"Worse, any who approach the Cursed can be driven mad by their terrible aura.",
		"Their most important stats are: Strength and Willpower",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +4 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = {psionic=true, technique=true},
	stats = { wil=4, str=5, },
	talents_types = {
		["cursed/gloom"]={true, 0.3},
		["cursed/slaughter"]={true, 0.3},
		["cursed/endless-hunt"]={true, 0.3},
		["cursed/strife"]={true, 0.3},
		["cursed/cursed-form"]={true, 0.0},
		["cursed/unyielding"]={true, 0.0},
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={false, 0.0},
		["cursed/rampage"]={false, 0.0},
		["cursed/predator"]={false, 0.0},
		["cursed/fears"]={false, 0.0},
	},
	talents = {
		[ActorTalents.T_UNNATURAL_BODY] = 1,
		[ActorTalents.T_GLOOM] = 1,
		[ActorTalents.T_SLASH] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		max_life = 110,
		resolvers.equip{ id=true,
			{type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
		chooseCursedAuraTree = true
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Doomed",
	locked = function() return profile.mod.allow_build.afflicted_doomed end,
	locked_desc = "In shaded places in unknown lands thou must overcome thyself and see thy doom.",
	desc = {
		"The Doomed are fallen mages who once wielded powerful magic wrought by ambition and dark bargains.",
		"Stripped of their magic by the dark forces that once served them, they have learned to harness the hatred that burns in their minds.",
		"Only time will tell if they can choose a new path or are doomed forever.",
		"The Doomed strike from behind a veil of darkness or a host of shadows.",
		"They feed upon their enemies as they unleash their minds on all who confront them.",
		"Their most important stats are: Willpower and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +4 Willpower, +5 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	power_source = {psionic=true},
	stats = { wil=4, cun=5, },
	talents_types = {
		["cursed/dark-sustenance"]={true, 0.3},
		["cursed/force-of-will"]={true, 0.3},
		["cursed/gestures"]={true, 0.3},
		["cursed/punishments"]={true, 0.3},
		["cursed/shadows"]={true, 0.3},
		["cursed/darkness"]={true, 0.3},
		["cursed/cursed-form"]={true, 0.0},
		["cunning/survival"]={false, 0.0},
		["cursed/fears"]={false, 0.0},
	},
	talents = {
		[ActorTalents.T_UNNATURAL_BODY] = 1,
		[ActorTalents.T_FEED] = 1,
		[ActorTalents.T_GESTURE_OF_PAIN] = 1,
		[ActorTalents.T_WILLFUL_STRIKE] = 1,
		[ActorTalents.T_CALL_SHADOWS] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
		chooseCursedAuraTree = true
	},
	copy_add = {
	},
}
