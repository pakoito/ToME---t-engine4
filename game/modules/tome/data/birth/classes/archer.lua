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
	name = "Archer",
	desc = {
		"Archers are dexterous ranged fighters, able to pin their foes to the ground and rain down a carpet of arrows on them.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Archer = "allow",
			Slinger = "allow",
		},
	},
	copy = {
		max_life = 110,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archer",
	desc = {
		"Archers are dexterous ranged fighters, able to pin their foes to the ground and rain down a carpet of arrows on them.",
		"Skilled archers can fire special shots that pierce, cripple or pin their foes.",
		"Their most important stats are: Dexterity and Strength",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +3 Strength, +5 Dexterity, +1 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
	},
	stats = { dex=5, str=3, con=1, },
	talents_types = {
		["technique/archery-training"]={true, 0.3},
		["technique/archery-utility"]={true, 0.3},
		["technique/archery-bow"]={true, 0.3},
		["technique/archery-sling"]={false, 0.1},
		["technique/combat-techniques-active"]={true, -0.1},
		["technique/combat-techniques-passive"]={false, -0.1},
		["technique/combat-training"]={true, 0.3},
		["technique/field-control"]={true, 0},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_FLARE] = 1,
		[ActorTalents.T_STEADY_SHOT] = 1,
		[ActorTalents.T_BOW_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true},
		},
		resolvers.generic(function(e)
			e.auto_shoot_talent = e.T_SHOOT
		end),
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Slinger",
	desc = {
		"Slingers are cunning ranged fighters, able to pin their targets to the ground and incapacitate their foes in various ways.",
		"Skilled slingers can fire special shots that knock back, blind or pin their foes.",
		"Their most important stats are: Dexterity and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +5 Dexterity, +1 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +3 Cunning",
	},
	stats = { dex=5, cun=3, con=1, },
	talents_types = {
		["technique/archery-training"]={true, 0.3},
		["technique/archery-utility"]={true, 0.3},
		["technique/archery-bow"]={false, 0.1},
		["technique/archery-sling"]={true, 0.3},
		["technique/combat-techniques-active"]={true, -0.1},
		["technique/combat-techniques-passive"]={false, -0.1},
		["technique/combat-training"]={true, 0.3},
		["technique/field-control"]={true, 0},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_FLARE] = 1,
		[ActorTalents.T_STEADY_SHOT] = 1,
		[ActorTalents.T_SLING_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		equipment = resolvers.equip{ id=true,
			{type="weapon", subtype="sling", name="rough leather sling", autoreq=true},
		},
	},
}
