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
	name = "Celestial",
	locked = function() return profile.mod.allow_build.divine end,
	locked_desc = "The magic of the heavens is known to but a few, and that knowledge has long passed east, forgotten.",
	desc = {
		"Celestial classes are arcane users focused on the heavenly bodies.",
		"Most draw their powers from the Sun and the Moons.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			['Sun Paladin'] = "allow-nochange",
			Anorithil = "allow-nochange",
		},
	},
	copy = {
		class_start_check = function(self)
			if self.descriptor.world == "Maj'Eyal" and (self.descriptor.race == "Human" or self.descriptor.race == "Elf") then
				self.celestial_race_start_quest = self.starting_quest
				self.default_wilderness = {"zone-pop", "ruined-gates-of-morning"}
				self.starting_zone = "town-gates-of-morning"
				self.starting_quest = "start-sunwall"
				self.starting_intro = "sunwall"
				self.faction = "sunwall"
			end
		end,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Sun Paladin",
	locked = function() return profile.mod.allow_build.divine_sun_paladin end,
	locked_desc = "The sun rises in the east in full glory, but you must look for it first amidst the darkest places.",
	desc = {
		"Sun Paladins hail from the Gates of Morning, the last bastion of the free people in the Far East.",
		"Their way of life is well represented by their motto 'The Sun is our giver, our purity, our essence. We carry the light into dark places, and against our strength none shall pass.'",
		"They can channel the power of the Sun to smite all who seek to destroy the Sunwall.",
		"Competent in both weapon and shield combat and magic, they usually burn their foes from afar before bashing them in melee.",
		"Their most important stats are: Strength and Magic",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +5 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +4 Magic, +0 Willpower, +0 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = {technique=true, arcane=true},
	stats = { mag=4, str=5, },
	talents_types = {
		["technique/shield-offense"]={true, 0.1},
		["technique/combat-techniques-active"]={false, 0.1},
		["technique/combat-techniques-passive"]={true, 0.1},
		["technique/combat-training"]={true, 0.1},
		["cunning/survival"]={false, 0.1},
		["celestial/sun"]={true, 0},
		["celestial/chants"]={true, 0.3},
		["celestial/combat"]={true, 0.3},
		["celestial/light"]={true, 0.3},
		["celestial/guardian"]={false, 0.3},
	},
	birth_example_particles = "golden_shield",
	talents = {
		[ActorTalents.T_SEARING_LIGHT] = 1,
		[ActorTalents.T_WEAPON_OF_LIGHT] = 1,
		[ActorTalents.T_CHANT_OF_FORTITUDE] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 3,
	},
	copy = {
		max_life = 110,
		resolvers.equip{ id=true,
			{type="weapon", subtype="mace", name="iron mace", ingore_material_restriction=true, autoreq=true, ego_chance=-1000},
			{type="armor", subtype="shield", name="iron shield", ingore_material_restriction=true, autoreq=true, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", ingore_material_restriction=true, autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = 2,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Anorithil",
	locked = function() return profile.mod.allow_build.divine_anorithil end,
	locked_desc = "The balance of the heavens' powers is a daunting task. Mighty are those that stand in the twilight places, wielding both light and darkness in their mind.",
	desc = {
		"Anorithils hail from the Gates of Morning, the last bastion of the free people in the Far East.",
		"Their way of life is well represented by their motto 'We stand betwixt the Sun and Moon, where light and darkness meet. In the grey twilight we seek our destiny.'",
		"They can channel the power of the Sun and the Moon to burn and tear apart all who seek to destroy the Sunwall.",
		"Masters of Sun and Moon magic, they usually burn their foes with Sun rays before calling the fury of the stars.",
		"Their most important stats are: Magic and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +6 Magic, +0 Willpower, +3 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +0",
	},
	power_source = {arcane=true},
	stats = { mag=6, cun=3, },
	talents_types = {
		["cunning/survival"]={false, 0.1},
		["celestial/sun"]={true, 0.3},
		["celestial/chants"]={true, 0.3},
		["celestial/glyphs"]={false, 0.3},
		["celestial/circles"]={false, 0.3},
		["celestial/eclipse"]={true, 0.3},
		["celestial/light"]={true, 0.3},
		["celestial/twilight"]={true, 0.3},
		["celestial/hymns"]={true, 0.3},
		["celestial/star-fury"]={true, 0.3},
	},
	birth_example_particles = "darkness_shield",
	talents = {
		[ActorTalents.T_SEARING_LIGHT] = 1,
		[ActorTalents.T_MOONLIGHT_RAY] = 1,
		[ActorTalents.T_HYMN_OF_SHADOWS] = 1,
		[ActorTalents.T_TWILIGHT] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", ingore_material_restriction=true, autoreq=true, ego_chance=-1000},
			{type="armor", subtype="cloth", name="linen robe", ingore_material_restriction=true, autoreq=true, ego_chance=-1000}
		},
	},
}
