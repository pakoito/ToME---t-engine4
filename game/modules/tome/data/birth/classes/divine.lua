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

newBirthDescriptor{
	type = "class",
	name = "Divine",
	desc = {
		"Divine class is composed of worshippers of many various gods and entities.",
		"They range from the worship of the Sun, the Moon, powerful spirits, ...",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			['Sun Paladin'] = function() return profile.mod.allow_build.divine_sun_paladin and "allow" or "disallow" end,
			Anorithil = function() return profile.mod.allow_build.divine_anorithil and "allow" or "disallow" end,
		},
	},
	copy = {
		-- All mages are of angolwen faction
		faction = "sunwall",
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Sun Paladin",
	desc = {
		"Sun Paladins hail from the Gates of Morning, the last bastion of the free people in the Far East.",
		"Their way of life is well represented by their motto 'We walk in the dark places no others will enter. We stand on the bridge, and no one may pass.'",
		"They can channel the power of the Sun to smite all who seek to destroy the Sunwall.",
		"Competent in both weapon and shield combat and magic they usually burn their foes from afar before engaging in melee.",
		"Their most important stats are: Strength and Magic",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +4 Magic, +0 Willpower, +0 Cunning",
	},
	stats = { mag=4, str=5, },
	talents_types = {
		["technique/shield-offense"]={true, 0.1},
		["technique/combat-techniques-active"]={false, 0.1},
		["technique/combat-techniques-passive"]={true, 0.1},
		["technique/combat-training"]={true, 0.1},
		["cunning/survival"]={false, 0.1},
		["divine/sun"]={true, 0},
		["divine/chants"]={true, 0.3},
		["divine/combat"]={true, 0.3},
		["divine/light"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SEARING_LIGHT] = 1,
		[ActorTalents.T_WEAPON_OF_LIGHT] = 1,
		[ActorTalents.T_CHANT_OF_FORTITUDE] = 1,
		[ActorTalents.T_HEAVY_ARMOUR_TRAINING] = 1,
	},
	copy = {
		max_life = 110,
		resolvers.equip{ id=true,
			{type="weapon", subtype="mace", name="iron mace", autoreq=true},
			{type="armor", subtype="shield", name="iron shield", autoreq=true},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true},
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Anorithil",
	desc = {
		"Anorithils hail from the Gates of Morning, the last bastion of the free people in the Far East.",
		"Their way of life is well represented by their motto 'We are Grey. We stand between the darkness and the light.'",
		"They can channel the power of the Sun and the Moon to burn and tear apart all who seek to destroy the Sunwall.",
		"Masters of sun and moon magic they usually burn their foes with sun rays before calling the fury of the stars.",
		"Their most important stats are: Magic and Cunning",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +6 Magic, +0 Willpower, +3 Cunning",
	},
	stats = { mag=6, cun=3, },
	talents_types = {
		["cunning/survival"]={false, 0.1},
		["divine/sun"]={true, 0.3},
		["divine/chants"]={true, 0.3},
		["divine/glyphs"]={false, 0.3},
		["divine/light"]={false, 0.3},
		["divine/twilight"]={true, 0.3},
		["divine/hymns"]={true, 0.3},
		["divine/star-fury"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_SEARING_LIGHT] = 1,
		[ActorTalents.T_MOONLIGHT_RAY] = 1,
		[ActorTalents.T_HYMN_OF_SHADOWS] = 1,
		[ActorTalents.T_TWILIGHT] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="robe", autoreq=true},
		},
	},
}
