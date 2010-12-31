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
	name = "Chronomancer",
	desc = {
		"With one foot literally in the past and one in the future Chronomancers manipulate the present at a whim and wield a power that only bows to nature's own need to keep the balance. The wake in spacetime they leave behind them makes their own Chronomantic abilities that much stronger and that much harder to control.  The wise Chronomancer learns to maintain the balance between his own thirst for cosmic power and the universe's need to flow undisturbed, for the hole he tears that amplifies his own abilities just may be the same hole that one day swallows his.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			["Paradox Mage"] = "allow",
			["Temporal Warden"] = "allow",
			["Infinite Traveler"] = "allow",
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Paradox Mage",
	desc = {
		"A Paradox Mage studies the very fabric of spacetime, learning not just to bend it but shape it and remake it.",
		"Most Paradox Mages lack basic skills that others take for granted (like general fighting sense), but they make up for it through control of cosmic forces.",
		"Paradox Mages start off with knowledge of all but the most complex Chronomantic schools.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning",
	},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["chronomancy/advanced-timetravel"]={true, 0.3},
		["chronomancy/chronomancy"]={true, 0.3},
		["chronomancy/energy"]={true, 0.3},
		["chronomancy/entropy"]={true, 0.3},
		["chronomancy/gravity"]={true, 0.3},
		["chronomancy/inertia"]={true, 0.3},
		["chronomancy/matter"]={true, 0.3},
		["chronomancy/paradox"]={true, 0.3},
		["chronomancy/probability"]={true, 0.3},
		["chronomancy/temporal-combat"]={true, 0.3},
		["chronomancy/threading"]={true, 0.3},
		["chronomancy/timetravel"]={true, 0.3},
		["chronomancy/weaving"]={true, 0.3},

	},
	talents = {
		[ActorTalents.T_ENTROPIC_SPHERE] = 1,
		[ActorTalents.T_REVISION] = 1,
			},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Temporal Warden",
	desc = {
		"The Temporal Wardens are warriors who have learned to use some of the less intricate Chronomantic schools.",
		"Competent in two-handed weapon usage as well as Chronomancy, they seek to control the battlefield while engaging in hand-to-hand combat.",
		"Having split their studies between Chronomancy and martial training, Temporal Wardens have learned to blend the two into one but will never learn the more advanced Chronomantic schools.",
		"Temporal Wardens start play with an excellent grasp on the schools of Gravity and Temporal Combat as well as an understanding of Time Travel and Spacetime Weaving.  While they have knowledge of the schools of Inertia, Matter, and Probability, they won't be able to advance in them until later.",
		"Their most important stats are: Strength, Magic, and Willpower",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +2 Magic, +2 Willpower, +0 Cunning",
	},
	stats = { wil=2, str=5, mag=2},
	talents_types = {
		["chronomancy/gravity"]={true, 0.3},
		["chronomancy/inertia"]={false, 0},
		["chronomancy/matter"]={false, 0},
		["chronomancy/probability"]={false, 0},
		["chronomancy/temporal-combat"]={true, 0.3},
		["chronomancy/timetravel"]={true, 0},
		["chronomancy/weaving"]={true, 0},
		["technique/2hweapon-cripple"]={true, 0.1},
		["technique/combat-techniques-active"]={false, 0.1},
		["technique/combat-techniques-passive"]={true, 0.1},
		["technique/combat-training"]={true, 0.1},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_CRUSHING_WEIGHT] = 1,
		[ActorTalents.T_STUNNING_BLOW] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_HEAVY_ARMOUR_TRAINING] = 1,
	},
	copy = {
		max_life = 100,
		resolvers.equip{ id=true,
			{type="weapon", subtype="greatmaul", name="iron greatmaul", autoreq=true},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true},
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Infinite Traveler",
	desc = {
		"Shadowblades are a blend of rogues that are touched by the gift of magic; able to kill with their daggers under a veil of stealth while casting spells to enhance their performance and survival.",
		"Their use of magic is innate and not really studied; as such they do not naturally regenerate mana and must use external means of recharging.",
		"They use the schools of Phantasm, Temporal, Divination and Conveyance magic to enhance their arts.",
		"Their most important stats are: Dexterity, Cunning and Magic",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +2 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +2 Magic, +2 Willpower, +3 Cunning",
	},
	stats = { dex=2, wil=2, mag=2, cun=3, },
	talents_types = {
		["chronomancy/advanced-timetravel"]={false, 0},
		["chronomancy/inertia"]={false, 0},
		["chronomancy/probability"]={true, 0.3},
		["chronomancy/temporal-combat"]={false, 0},
		["chronomancy/threading"]={true, 0},
		["chronomancy/timetravel"]={true, 0.3},
		["chronomancy/weaving"]={true, 0.3},
		["technique/dualweapon-training"]={true, 0.2},
		["technique/combat-techniques-active"]={true, 0.1},
		["technique/combat-training"]={true, 0.2},
		["cunning/stealth"]={false, 0.3},
		["cunning/survival"]={true, 0.1},
		["cunning/lethality"]={true, 0.3},
		["cunning/dirty"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_DIRTY_FIGHTING] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_BACKTRACK] = 1,
		[ActorTalents.T_LETHALITY] = 1,
	},
	copy = {
		max_life = 100,
		equipment = resolvers.equip{ id=true,
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true}
		},
	},
}
