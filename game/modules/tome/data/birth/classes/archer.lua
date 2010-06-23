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

newBirthDescriptor{
	type = "class",
	name = "Archer",
	desc = {
		"Archers.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "never",
			Archer = "allow",
			Slinger = "allow",
		},
	},
	copy = {
		max_life = 110,
		life_rating = 10,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archer",
	desc = {
		"Archer",
		"Their most important stats are: Dexterity and Strength",
	},
	stats = { dex=7, str=4, con=1, },
	talents_types = {
		["technique/archery-training"]={true, 0.3},
		["technique/archery-utility"]={true, 0.3},
		["technique/archery-bow"]={true, 0.3},
		["technique/archery-sling"]={false, 0.1},
		["technique/combat-techniques-active"]={true, -0.1},
		["technique/combat-techniques-passive"]={false, -0.1},
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_AMMO_CREATION] = 1,
		[ActorTalents.T_STEADY_SHOT] = 1,
		[ActorTalents.T_BOW_MASTERY] = 2,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		equipment = resolvers.equip{ id=true,
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true},
			{type="ammo", subtype="arrow", name="elm arrow", autoreq=true},
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Slinger",
	desc = {
		"Slinger",
		"Their most important stats are: Dexterity and Cunning",
	},
	stats = { dex=7, str=4, con=1, },
	talents_types = {
		["technique/archery-training"]={true, 0.3},
		["technique/archery-utility"]={true, 0.3},
		["technique/archery-bow"]={false, 0.1},
		["technique/archery-sling"]={true, 0.3},
		["technique/combat-techniques-active"]={true, -0.1},
		["technique/combat-techniques-passive"]={false, -0.1},
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_AMMO_CREATION] = 1,
		[ActorTalents.T_STEADY_SHOT] = 1,
		[ActorTalents.T_SLING_MASTERY] = 2,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		equipment = resolvers.equip{ id=true,
			{type="weapon", subtype="sling", name="rough leather sling", autoreq=true},
			{type="ammo", subtype="shot", name="iron shot", autoreq=true},
		},
	},
}
