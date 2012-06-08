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
	name = "Psionic",
	locked = function() return profile.mod.allow_build.psionic end,
	locked_desc = "Weakness of flesh can be overcome by mental prowess. Find the way and fight for the way to open the key to your mind.",
	desc = {
		"Psionics find their power within themselves. Their highly trained minds can harness energy from many different sources and manipulate it to produce physical effects.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Mindslayer = "allow",
			Psion = "allow",
		},
	},
	copy = {
		psi_regen = 0.2,
	},
	body = { PSIONIC_FOCUS = 1, QS_PSIONIC_FOCUS = 1,},
}

newBirthDescriptor{
	type = "subclass",
	name = "Mindslayer",
	locked = function() return profile.mod.allow_build.psionic_mindslayer end,
	locked_desc = "A thought can inspire; a thought can kill. After centuries of oppression, years of imprisonment, a thought shall break us free and vengeance will strike from our darkest dreams.",
	desc = {
		"Mindslayers specialize in direct and brutal application of mental forces to their immediate surroundings.",
		"When Mindslayers do battle, they will most often be found in the thick of the fighting, vast energies churning around them and telekinetically-wielded weapons hewing nearby foes at the speed of thought.",
		"Their most important stats are: Willpower and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +1 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +4 Willpower, +4 Cunning",
	},
	power_source = {psionic=true},
	stats = { str=1, wil=4, cun=4, },
	talents_types = {
		--Level 0 trees:
		["psionic/absorption"]={true, 0.3},
		["psionic/projection"]={true, 0.3},
		["psionic/psi-fighting"]={true, 0.3},
		["psionic/focus"]={true, 0.3},
		["psionic/mental-discipline"]={true, 0.3},
		["psionic/voracity"]={true, 0.3},
		--Level 10 trees:
		["psionic/finer-energy-manipulations"]={false, 0},
		["psionic/psi-archery"]={false, 0.3},
		--Level 20 trees:
		["psionic/grip"]={false, 0},
		["psionic/augmented-mobility"]={false, 0},
		--Miscellaneous trees:
		["cunning/survival"]={true, 0},
		["technique/combat-training"]={true, 0},

	},
	talents = {
		[ActorTalents.T_KINETIC_SHIELD] = 1,
		[ActorTalents.T_KINETIC_AURA] = 1,
		[ActorTalents.T_KINETIC_LEECH] = 1,
		[ActorTalents.T_BEYOND_THE_FLESH] = 1,
		[ActorTalents.T_TRAP_HANDLING] = 1,
		[ActorTalents.T_TELEKINETIC_GRASP] = 1,
		[ActorTalents.T_TELEKINETIC_SMASH] = 1,
		[ActorTalents.T_SHOOT] = 1,
	},
	copy = {
		max_life = 110,
		resolvers.equip{ id=true,
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="greatsword", name="iron greatsword", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventory{ id=true,
			{type="gem",},
			{type="weapon", subtype="longbow", name="elm longbow", ego_chance=-1000},
			{type="ammo", subtype="arrow", name="quiver of elm arrows", autoreq=true, ego_chance=-1000},
		},
		resolvers.generic(function(self)
			-- Make and wield some alchemist gems
			local gs = game.zone:makeEntity(game.level, "object", {type="weapon", subtype="greatsword", name="iron greatsword", ego_chance=-1000}, nil, true)
			if gs then
				local pf = self:getInven("PSIONIC_FOCUS")
				if pf then
					self:addObject(pf, gs)
					gs:identify(true)
				end
			end
		end),
	},
	copy_add = {
		life_rating = -4,
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Psion",
	locked = function() return profile.mod.allow_build.psionic_psion end,
	locked_desc = "TODO",
	desc = {
		"blahblah",
		"Their most important stats are: Willpower and Cunning",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +1 Strength, +0 Dexterity, +0 Constitution",
		"#LIGHT_BLUE# * +0 Magic, +4 Willpower, +4 Cunning",
	},
	not_on_random_boss = true,
	power_source = {psionic=true},
	stats = { str=0, wil=5, cun=4, },
	talents_types = {
		["psionic/possession"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_POSSESS] = 1,
	},
	copy = {
		max_life = 90,
		resolvers.equip{ id=true,
			{type="armor", subtype="cloth", name="linen robe", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
			{type="weapon", subtype="mindstar", name="mossy mindstar", autoreq=true, ego_chance=-1000},
		},
	},
	copy_add = {
		life_rating = -4,
	},
}
