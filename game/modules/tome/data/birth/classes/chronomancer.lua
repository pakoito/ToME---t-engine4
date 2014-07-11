-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
		-- Chronomancers start in Point Zero
		class_start_check = function(self)
			if self.descriptor.world == "Maj'Eyal" and (self.descriptor.race ~= "Undead" and self.descriptor.race ~= "Dwarf" and self.descriptor.race ~= "Yeek") then
				self.chronomancer_race_start_quest = self.starting_quest
				self.default_wilderness = {"zone-pop", "angolwen-portal"}
				self.starting_zone = "town-point-zero"
				self.starting_quest = "start-point-zero"
				self.starting_intro = "chronomancer"
				self.faction = "keepers-of-reality"
				self:learnTalent(self.T_TELEPORT_POINT_ZERO, true, nil, {no_unlearn=true})
			end
		end,
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
		"Their most important stats are: Magic, Constitution, and Willpower",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +2 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +2 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	power_source = {arcane=true},
	random_rarity = 2,
	stats = { mag=5, wil=2, con=2, },
	talents_types = {
		["chronomancy/age-manipulation"]={true, 0.3},
	--	["chronomancy/anomalies"]={true, 0},
		["chronomancy/chronomancy"]={true, 0.3},
		["chronomancy/energy"]={true, 0.3},
		["chronomancy/fate-threading"]={true, 0.3},
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
		[ActorTalents.T_DISENTANGLE] = 1,
		[ActorTalents.T_DIMENSIONAL_STEP] = 1,
		[ActorTalents.T_DUST_TO_DUST] = 1,
		[ActorTalents.T_TURN_BACK_THE_CLOCK] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Temporal Warden",
	locked = function() return profile.mod.allow_build.chronomancer_temporal_warden end,
	locked_desc = "We preserve the past to protect the future. The hands of time are guarded by the arms of war.",
	desc = {
		"The Temporal Wardens have learned to blend archery, dual-weapon fighting, and chronomancy into a fearsome whole.",
		"Their study of chronomancy enables them to amplify their own physical and magical abilities, and to manipulate the speed of themselves and those around them.",
		"Their most important stats are: Magic, Dexterity, Constitution, and Willpower",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +2 Dexterity, +2 Constitution",
		"#LIGHT_BLUE# * +3 Magic, +2 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = {technique=true, arcane=true},
	random_rarity = 2,
	stats = { con=2, wil=2, dex=3, mag=2},
	talents_types = {
		-- class
		["chronomancy/blade-threading"]={true, 0.3},
		["chronomancy/bow-threading"]={true, 0.3},
		["chronomancy/fate-threading"]={true, 0.3},
		["chronomancy/spacetime-folding"]={true, 0.3},
		["chronomancy/speed-control"]={true, 0.1},
		["chronomancy/guardian"]={true, 0.3},
		
		["chronomancy/threaded-combat"]={false, 0.3},
		["chronomancy/temporal-hounds"]={false, 0.3},
		["chronomancy/timetravel"]={false, 0.1},
		
		-- generic
		["cunning/survival"]={false, 0},
		["technique/combat-training"]={true, 0.3},
		["chronomancy/chronomancy"]={true, 0.3},
		["chronomancy/fate-weaving"]={false, 0.1},
		["chronomancy/spacetime-weaving"]={true, 0.3},
	},
	birth_example_particles = "temporal_focus",
	talents = {
		[ActorTalents.T_SHOOT] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		
		[ActorTalents.T_WARP_BLADE] = 1,
		[ActorTalents.T_IMPACT] = 1,
		[ActorTalents.T_DIMENSIONAL_STEP] = 1,
		[ActorTalents.T_STRENGTH_OF_PURPOSE] = 1,
	},
	copy = {
		max_life = 100,
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="dagger", name="iron dagger", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventorybirth{ id=true, inven="QS_MAINHAND",
			{type="weapon", subtype="longbow", name="elm longbow", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventorybirth{ id=true, inven="QS_QUIVER",
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
		},
		resolvers.generic(function(e)
			e.auto_shoot_talent = e.T_SHOOT
		end),
	},
	copy_add = {
		life_rating = 2,
	},
}
