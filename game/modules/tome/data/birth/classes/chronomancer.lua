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
	name = "Chronomancer",
	locked = function() return profile.mod.allow_build.chronomancer end,
	locked_desc = "Some do not walk upon the straight road others follow. Seek the hidden paths outside the normal course of life.",
	desc = {
		"With one foot literally in the past and one in the future, Chronomancers manipulate the present at a whim and wield a power that only bows to nature's own need to keep the balance. The wake in spacetime they leave behind them makes their own Chronomantic abilites that much stronger and that much harder to control.  The wise Chronomancer learns to maintain the balance between his own thirst for cosmic power and the universe's need to flow undisturbed, for the hole he tears that amplifies his own abilities just may be the same hole that one day swallows him.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			["Paradox Mage"] = "allow",
			["Temporal Warden"] = "allow",
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Paradox Mage",
	locked = function() return profile.mod.allow_build.chronomancer_paradox_mage end,
	locked_desc = "A hand may clap alone if it returns to clap itself. Search for the power in the paradox.",
	desc = {
		"A Paradox Mage studies the very fabric of spacetime, learning not just to bend it but shape it and remake it.",
		"Most Paradox Mages lack basic skills that others take for granted (like general fighting sense), but they make up for it through control of cosmic forces.",
		"Paradox Mages start off with knowledge of all but the most complex Chronomantic schools.",
		"Their most important stats are: Magic and Willpower",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +3 Willpower, +1 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# -4",
	},
	power_source = {arcane=true},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["chronomancy/age-manipulation"]={true, 0.3},
	--	["chronomancy/anomalies"]={true, 0},
		["chronomancy/chronomancy"]={true, 0.3},
		["chronomancy/energy"]={true, 0.3},
		["chronomancy/gravity"]={true, 0.3},
		["chronomancy/matter"]={true, 0.3},
		["chronomancy/paradox"]={false, 0.3},
		["chronomancy/speed-control"]={true, 0.3},
		["chronomancy/timeline-threading"]={false, 0.3},
		["chronomancy/timetravel"]={true, 0.3},
		["chronomancy/spacetime-weaving"]={true, 0.3},
		["cunning/survival"]={false, 0},
	},
	talents = {
		[ActorTalents.T_SPACETIME_TUNING] = 1,
		[ActorTalents.T_STATIC_HISTORY] = 1,
		[ActorTalents.T_DIMENSIONAL_STEP] = 1,
		[ActorTalents.T_DUST_TO_DUST] = 1,
		[ActorTalents.T_TURN_BACK_THE_CLOCK] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Temporal Warden",
	locked = function() return profile.mod.allow_build.chronomancer_temporal_warden end,
	locked_desc = "We preserve the past to protect the future. The hands of time are guarded by the arms of war.",
	desc = {
		"The Temporal Wardens have learned to blend archery, dual-weapon fighting, and chronomancy into a fearsome whole.",
		"Through their use of the chronomantic arts, the Temporal Wardens seek to control the battlefield while peppering their foes with arrows or engaging in hand-to-hand combat.",
		"Their study of chronomancy enables them to amplify their own physical and magical abilities, and to manipulate the speed of themselves and those around them.",
		"Their most important stats are: Strength, Dexterity, Willpower, and Magic",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +2 Strength, +3 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +2 Magic, +2 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	power_source = {technique=true, arcane=true},
	stats = { str=2, wil=2, dex=3, mag=2},
	talents_types = {
		["technique/archery-bow"]={true, 0},
		["technique/archery-utility"]={false, 0},
		["technique/dualweapon-attack"]={true, 0},
		["technique/dualweapon-training"]={false, 0},
		["technique/combat-training"]={true, 0.1},
		["cunning/survival"]={false, 0},
		["chronomancy/chronomancy"]={true, 0.1},
		["chronomancy/speed-control"]={true, 0.1},
	--	["chronomancy/temporal-archery"]={true, 0.3},
		["chronomancy/temporal-combat"]={true, 0.3},
		["chronomancy/timetravel"]={false, 0},
		["chronomancy/spacetime-weaving"]={true, 0},
		["chronomancy/spacetime-folding"]={true, 0.3},
	},
	birth_example_particles = "temporal_focus",
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_SPACETIME_TUNING] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_DUAL_STRIKE] = 1,
		[ActorTalents.T_CELERITY] = 1,
		[ActorTalents.T_STRENGTH_OF_PURPOSE] = 1,
	},
	copy = {
		max_life = 100,
		resolvers.equip{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventory{ id=true, inven="QS_MAINHAND",
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventory{ id=true, inven="QS_QUIVER",
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
		},
	},
}
