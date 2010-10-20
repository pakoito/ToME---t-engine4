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
	name = "Wilder",
	desc = {
		"Wilders are one with nature, in one manner or another. There are as many different wilders as there are aspects of nature.",
		"They can take on the aspects of creatures, summon creatures to them, feel the druidic call, ...",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Summoner = function() return profile.mod.allow_build.wilder_summoner and "allow" or "disallow" end,
			Wyrmic = function() return profile.mod.allow_build.wilder_wyrmic and "allow" or "disallow" end,
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Summoner",
	desc = {
		"Summoners never fight alone, they are always ready to summon one of their many minions to fight at their side.",
		"Summons can range from a combat hound to a fire drake.",
		"Their most important stats are: Willpower and Cunning",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +1 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +5 Willpower, +3 Cunning",
	},
	stats = { wil=5, cun=3, con=1, },
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/summon-melee"]={true, 0.3},
		["wild-gift/summon-distance"]={true, 0.3},
		["wild-gift/summon-utility"]={true, 0.3},
		["wild-gift/summon-augmentation"]={false, 0.3},
		["cunning/survival"]={true, 0},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={false, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_WAR_HOUND] = 1,
		[ActorTalents.T_FIRE_IMP] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_TRAP_DETECTION] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true}
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Wyrmic",
	desc = {
		"Wyrmics are fighters who have learnt how to mimic some of the aspects of the dragons.",
		"They have access to talents normally belonging to the various kind of drakes.",
		"Their most important stats are: Strength and Willpower",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +1 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +3 Willpower, +0 Cunning",
	},
	stats = { str=5, wil=3, dex=1, },
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/sand-drake"]={true, 0.3},
		["wild-gift/fire-drake"]={true, 0.3},
		["wild-gift/cold-drake"]={true, 0.3},
		["wild-gift/storm-drake"]={true, 0.3},
		["cunning/survival"]={false, 0},
		["technique/shield-offense"]={false, -0.1},
		["technique/2hweapon-offense"]={true, -0.1},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={true, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_ICE_CLAW] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_WEAPONS_MASTERY] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		max_life = 110,
		resolvers.equip{ id=true,
			{type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true}
		},
	},
	copy_add = {
		life_rating = 2,
	},
}
