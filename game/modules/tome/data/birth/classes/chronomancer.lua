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
		"With one foot literally in the past and one in the future Chronomancers manipulate the present at a whim and wield a power that only bows to nature's own need to keep the balance. The wake in spacetime they leave behind them makes their own Chronomantic abilites that much stronger and that much harder to control.  The wise Chronomancer learns to maintain the balance between his own thirst for cosmic power and the universe's need to flow undisturbed, for the hole he tears that amplifies his own abilities just may be the same hole that one day swallows him.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			["Paradox Mage"] = function() return profile.mod.allow_build.chronomancer_paradox_mage and "allow" or "disallow" end,
			["Temporal Warden"] = function() return profile.mod.allow_build.chronomancer_temporal_warden and "allow" or "disallow" end,
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
		["chronomancy/age-manipulation"]={true, 0.3},
		["chronomancy/anomalies"]={true, 0},
		["chronomancy/chronomancy"]={true, 0.3},
		["chronomancy/energy"]={true, 0.3},
		["chronomancy/gravity"]={true, 0.3},
		["chronomancy/matter"]={true, 0.3},
		["chronomancy/paradox"]={true, 0.3},
		["chronomancy/probability"]={true, 0.3},
		["chronomancy/speed-control"]={true, 0.3},
		["chronomancy/temporal-combat"]={true, 0.3},
		["chronomancy/timeline-threading"]={true, 0.3},
		["chronomancy/timetravel"]={true, 0.3},
		["chronomancy/spacetime-weaving"]={true, 0.3},

	},
	talents = {
		[ActorTalents.T_STATIC_HISTORY] = 1,
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
		"The Temporal Warden has learned to blend archery, dual-weapon fighting, and chronomancy into a fearsome whole.",
		"Through their use of the chronomantic arts the Temporal Warden seeks to control the battle field while they pepper their foes with arrows or engage in hand-to-hand combat.",
		"Their study of chronomancy enables them to amplify their own physical and magical abilities and manipulate the speed of themselves and those around them.",
		"The Temporal Warden starts play with a longsword and dagger equipped and a bow in their inventory, if you wish to make use of their ranged attacks remember to equip your bow in your secondary weapon slot for easy access.",
		"Their most important stats are: Strength, Dexterity, Willpower, and Magic",
		"#GOLD#Stats modifiers:",
		"#LIGHT_BLUE# * +2 Strength, +3 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +2 Magic, +2 Willpower, +0 Cunning",
	},
	stats = { str=2, wil=2, dex=3, mag=2},
	talents_types = {
		["technique/archery-bow"]={false, 0.1},
		["technique/archery-utility"]={true, 0.1},
		["technique/dualweapon-attack"]={true, 0.1},
		["technique/dualweapon-training"]={false, 0.1},
		["technique/combat-training"]={true, 0.2},
		["cunning/lethality"]={false, 0},
		["cunning/survival"]={false, 0},
		["chronomancy/chronomancy"]={true, 0.1},
		["chronomancy/speed-control"]={true, 0.1},
		["chronomancy/temporal-archery"]={true, 0.3},
		["chronomancy/temporal-combat"]={true, 0.3},
		["chronomancy/timetravel"]={false, 0},
		["chronomancy/spacetime-weaving"]={true, 0},
	},
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_DUAL_STRIKE] = 1,
		[ActorTalents.T_CELERITY] = 1,
		[ActorTalents.T_STRENGTH_OF_PURPOSE] = 1,
		},
	copy = {
		max_life = 100,
		resolvers.equip{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true},
		},
		resolvers.inventory{ id=true, inven="QS_MAINHAND",
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true},
		},
	},
}
