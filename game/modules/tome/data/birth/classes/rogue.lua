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
	name = "Rogue",
	desc = {
		"Rogues are masters of tricks; they can strike from the shadows, and lure monsters into deadly traps.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Rogue = "allow",
			Shadowblade = "allow",
			Marauder = "allow",
		},
	},
	copy = {
		max_life = 100,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Rogue",
	desc = {
		"Rogues are masters of tricks. A Rogue can get behind you unnoticed and stab you in the back for tremendous damage.",
		"Rogues usually prefer to dual-wield daggers. They can also become trapping experts, detecting and disarming traps as well as setting them.",
		"Their most important stats are: Dexterity and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +1 Strength, +3 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +5 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	power_source = {technique=true},
	stats = { dex=3, str=1, cun=5, },
	talents_types = {
		["technique/dualweapon-attack"]={true, 0.3},
		["technique/dualweapon-training"]={true, 0.3},
		["technique/combat-techniques-active"]={false, 0.3},
		["technique/combat-techniques-passive"]={false, 0.3},
		["technique/combat-training"]={true, 0.3},
		["technique/field-control"]={false, 0},
		["cunning/stealth"]={true, 0.3},
		["cunning/trapping"]={true, 0.3},
		["cunning/dirty"]={true, 0.3},
		["cunning/lethality"]={true, 0.3},
		["cunning/survival"]={true, 0.3},
		["cunning/scoundrel"]={true, 0.3},
	},
	unlockable_talents_types = {
		["cunning/poisons"]={false, 0.3, "rogue_poisons"},
	},
	talents = {
		[ActorTalents.T_STEALTH] = 1,
		[ActorTalents.T_TRAP_MASTERY] = 1,
		[ActorTalents.T_LETHALITY] = 1,
		[ActorTalents.T_DUAL_STRIKE] = 1,
	},
	copy = {
		equipment = resolvers.equip{ id=true,
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Shadowblade",
	desc = {
		"Shadowblades are Rogues that are touched by the gift of magic, able to kill with their daggers under a veil of stealth while casting spells to enhance their performance and survival.",
		"Their use of magic is innate and not really studied; as such they do not naturally regenerate mana and must use external means of recharging.",
		"They use the schools of Phantasm, Temporal, Divination and Conveyance magic to enhance their arts.",
		"Their most important stats are: Dexterity, Cunning and Magic",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +3 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +3 Magic, +0 Willpower, +3 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	power_source = {technique=true, arcane=true},
	stats = { dex=3, mag=3, cun=3, },
	talents_types = {
		["spell/phantasm"]={true, 0},
		["spell/temporal"]={false, 0},
		["spell/divination"]={false, 0},
		["spell/conveyance"]={true, 0},
		["technique/dualweapon-attack"]={true, 0.2},
		["technique/dualweapon-training"]={true, 0.2},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={false, 0.3},
		["technique/combat-training"]={true, 0.2},
		["cunning/stealth"]={false, 0.3},
		["cunning/survival"]={true, 0.1},
		["cunning/lethality"]={true, 0.3},
		["cunning/dirty"]={true, 0.3},
		["cunning/shadow-magic"]={true, 0.3},
		["cunning/ambush"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_DUAL_STRIKE] = 1,
		[ActorTalents.T_SHADOW_COMBAT] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
		[ActorTalents.T_LETHALITY] = 1,
	},
	copy = {
		resolvers.inscription("RUNE:_MANASURGE", {cooldown=25, dur=10, mana=620}),
		equipment = resolvers.equip{ id=true,
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000}
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Marauder",
	locked = function() return profile.mod.allow_build.rogue_marauder end,
	locked_desc = "I will not hide and I will not sneak - come dance with my blades and we'll see who's weak. Snapping bone and cracking skull, it's the sounds of battle that make life full!",
	desc = {
		"The wilds of Maj'Eyal are not a safe place. Untamed beasts and wandering dragons may seem a great threat, but the true perils walk on two legs. Thieves and brigands, assassins and opportunistic adventurers, even mad wizards and magic-hating zealouts all carry danger to those who venture beyond the safety of city walls.",
		"Amidst this chaos wanders one class of rogue that has learned to take by force rather than subterfuge. With refined techniques, agile feats and brawn-backed blades the Marauder seeks out his targets and removes them by the most direct methods. He uses dual weapons backed by advanced combat training to become highly effective in battle, and he is unafraid to use the dirtiest tactics when the odds are against him.",
		"Their most important stats are: Strength, Dexterity and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +4 Strength, +4 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +0 Willpower, +1 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	stats = { dex=4, str=4, cun=1, },
	talents_types = {
		["technique/dualweapon-attack"]={true, 0.2},
		["technique/dualweapon-training"]={true, 0.2},
		["technique/combat-techniques-active"]={true, 0.3},
		["technique/combat-techniques-passive"]={false, 0.0},
		["technique/combat-training"]={true, 0.3},
		["technique/field-control"]={true, 0.3},
		["technique/battle-tactics"]={false, 0.2},
		["technique/mobility"]={true, 0.3},
		["technique/thuggery"]={true, 0.3},
		["technique/conditioning"]={true, 0.3},
		["cunning/dirty"]={true, 0.3},
		["cunning/tactical"]={false, 0.2},
		["cunning/survival"]={true, 0.3},
	},
	unlockable_talents_types = {
		["cunning/poisons"]={false, -0.1, "rogue_poisons"},
	},
	talents = {
		[ActorTalents.T_DIRTY_FIGHTING] = 1,
		[ActorTalents.T_SKULLCRACKER] = 1,
		[ActorTalents.T_HACK_N_BACK] = 1,
		[ActorTalents.T_DUAL_STRIKE] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
	},
	copy = {
		equipment = resolvers.equip{ id=true,
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="head", name="iron helm", autoreq=true, ego_chance=-1000},
		},
	},
}
