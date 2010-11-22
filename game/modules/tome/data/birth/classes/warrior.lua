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
	name = "Warrior",
	desc = {
		"Warriors train in all aspects of physical combat. They can be juggernauts of destruction wielding a two-handed greatsword, or massive iron-clad protectors with a shield.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Fighter = "allow",
			Berserker = "allow",
			["Arcane Blade"] = "allow",
		},
	},
	copy = {
		max_life = 120,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Fighter",
	desc = {
		"A Fighter specializes in weapon and shield combat, rarely leaving the cover of her many protective techniques.",
		"A good Fighter is able to withstand terrible attacks from all sides, protected by her shield, and when the time comes lash out at her foes with incredible strength.",
		"Their most important stats are: Strength and Dexterity",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +2 Dexterity, +2 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
	},
	stats = { str=5, con=2, dex=2, },
	talents_types = {
		["technique/archery-training"]={false, 0.1},
		["technique/shield-offense"]={true, 0.3},
		["technique/shield-defense"]={true, 0.3},
		["technique/2hweapon-offense"]={false, -0.1},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={true, 0.3},
		["technique/combat-training"]={true, 0.3},
		["technique/superiority"]={false, 0.3},
		["technique/warcries"]={false, 0.3},
		["technique/field-control"]={false, 0},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SHIELD_PUMMEL] = 1,
		[ActorTalents.T_REPULSION] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_HEAVY_ARMOUR_TRAINING] = 1,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true},
			{type="armor", subtype="shield", name="iron shield", autoreq=true},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true}
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Berserker",
	desc = {
		"A Berserker wields huge two-handed weapons of destruction, bringing pain and death to his foes as he cleaves them in two.",
		"A Berserker usually forfeits all ideas of self-defense to concentrate on what he does best: killing things.",
		"Their most important stats are: Strength and Constitution",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +1 Dexterity, +3 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +0 Cunning",
	},
	stats = { str=5, con=3, dex=1, },
	talents_types = {
		["technique/archery-training"]={false, 0.1},
		["technique/shield-defense"]={false, -0.1},
		["technique/2hweapon-offense"]={true, 0.3},
		["technique/2hweapon-cripple"]={true, 0.3},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={true, 0.3},
		["technique/combat-training"]={true, 0.3},
		["technique/superiority"]={false, 0.3},
		["technique/warcries"]={false, 0.3},
		["technique/field-control"]={false, 0},
		["technique/bloodthirst"]={false, 0.2},
		["cunning/survival"]={true, 0},
		["cunning/dirty"]={false, 0},
	},
	talents = {
		[ActorTalents.T_DEATH_DANCE] = 1,
		[ActorTalents.T_STUNNING_BLOW] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_HEAVY_ARMOUR_TRAINING] = 1,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true},
		},
	},
	copy_add = {
		life_rating = 3,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Arcane Blade",
	desc = {
		"The Arcane Blade is a warrior who has been touched by the gift of magic.",
		"Their use of magic is innate and not really studied; as such they do not naturally regenerate mana and must use external means of recharging.",
		"They can cast spells from a limited selection but have the unique capacity to 'channel' their attack spells through their melee attacks.",
		"They are adept at two-handed weapons, for the sheer destruction they can bring.",
		"Their most important stats are: Strength, Dexterity and Magic",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +3 Strength, +3 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +3 Magic, +0 Willpower, +0 Cunning",
	},
	stats = { mag=3, str=3, dex=3},
	talents_types = {
		["spell/fire"]={true, 0.2},
		["spell/air"]={true, 0.2},
		["spell/conveyance"]={false, 0.2},
		["spell/divination"]={false, 0.2},
		["spell/enhancement"]={true, 0.2},
		["technique/2hweapon-cripple"]={true, 0.1},
		["technique/combat-techniques-active"]={true, 0.1},
		["technique/combat-techniques-passive"]={false, 0.1},
		["technique/combat-training"]={true, 0.1},
		["technique/magical-combat"]={true, 0.3},
		["cunning/survival"]={true, -0.1},
		["cunning/dirty"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_ARCANE_COMBAT] = 1,
		[ActorTalents.T_STUNNING_BLOW] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		max_life = 100,
		talent_cd_reduction={[ActorTalents.T_FLAME]=-3, [ActorTalents.T_LIGHTNING]=-3, },
		resolvers.equip{ id=true,
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true},
		},
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=25, dur=10, mana=620}),
	},
	copy_add = {
		life_rating = 2,
	},
}
