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
	name = "Corrupter",
	desc = {
		"Corrupters are touched by the mark of evil. They are a blight on the world. Working to promote the cause of evil, they serve their masters, or themselves become masters.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Reaver = function() return profile.mod.allow_build.corrupter_reaver and "allow" or "disallow" end,
			Corruptor = function() return profile.mod.allow_build.corrupter_corruptor and "allow" or "disallow" end,
		},
	},
	copy = {
		max_life = 120,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Reaver",
	desc = {
		"A Reaver is a terrible foe, wielding two weapons while charging his foes.",
		"They can harness the blight of evil, infecting their foes with terrible contagious diseases while crushing their skulls with devastating combat techniques.",
		"Their most important stats are: Strength and Magic",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +4 Strength, +1 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +4 Magic, +0 Willpower, +0 Cunning",
	},
	stats = { str=4, mag=4, dex=1, },
	talents_types = {
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={false, 0.1},
		["corruption/sanguisuge"]={true, 0.3},
		["corruption/reaving-combat"]={true, 0.3},
		["corruption/scourge"]={true, 0.3},
		["corruption/plague"]={true, 0.3},
		["corruption/hexes"]={false, 0.3},
		["corruption/curses"]={false, 0.3},
		["corruption/bone"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_CORRUPTED_STRENGTH] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_BLOOD_SACRIFICE] = 1,
		[ActorTalents.T_REND] = 1,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="waraxe", name="iron waraxe", autoreq=true},
			{type="weapon", subtype="waraxe", name="iron waraxe", autoreq=true},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true}
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Corruptor",
	desc = {
		"A corruptor is a terrible foe, wielding dark magics that can sap the very soul of her target.",
		"They can harness the blight of evil, crushing souls, stealing life force to replenish themselves.",
		"The most powerful corruptors can even take on some demonic aspects for themselves.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +2 Constitution",
		"#LIGHT_BLUE# * +4 Magic, +3 Willpower, +0 Cunning",
	},
	stats = { mag=4, wil=3, con=2, },
	talents_types = {
		["cunning/survival"]={false, 0},
		["corruption/sanguisuge"]={true, 0.3},
		["corruption/hexes"]={true, 0.3},
		["corruption/curses"]={true, 0.3},
		["corruption/bone"]={false, 0.3},
		["corruption/plague"]={true, 0.3},
		["corruption/shadowflame"]={false, 0.3},
		["corruption/blood"]={true, 0.3},
		["corruption/vim"]={true, 0.3},
		["corruption/blight"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_BLOOD_SACRIFICE] = 1,
		[ActorTalents.T_BLOOD_GRASP] = 1,
		[ActorTalents.T_SOUL_ROT] = 1,
		[ActorTalents.T_PACIFICATION_HEX] = 1,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true}
		},
	},
}
