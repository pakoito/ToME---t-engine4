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
	name = "Mage",
	desc = {
		"Mages are the wielder of the arcane powers. Able to cast powerful spells of destruction or to heal their wounds with nothing but a thought.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "never",
			["Arcane Blade"] = "allow",
			Archmage = "allow",
--			Necromancer = "allow",
		},
	},
	copy = {
		resolvers.generic(function(e)
			e.hotkey[10] = {"inventory", "potion of lesser mana"}
		end),
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archmage",
	desc = {
		"An Archmage devote her whole life to the study of magic above anything else.",
		"Most archmagi lack basic skills that others take for granted (like general fighting sense), but they make up for it by their raw magical power.",
		"Archmagi know all schools of magic but the more intricates(Temporal and Meta) from the start. They however usualy refuse to have anything to do with Necromancy.",
		"Their most important stats are: Magic and Willpower",
	},
	stats = { mag=3, wil=2, cun=1, },
	talents_types = {
		["spell/arcane"]={true, 0.3},
		["spell/fire"]={true, 0.3},
		["spell/earth"]={true, 0.3},
		["spell/water"]={true, 0.3},
		["spell/air"]={true, 0.3},
		["spell/phantasm"]={true, 0.3},
		["spell/temporal"]={false, 0.3},
		["spell/meta"]={false, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["spell/nature"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_MANATHRUST] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_FREEZE] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
	},
	copy = {
		max_life = 90,
		life_rating = 10,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="robe", autoreq=true}
		},
		resolvers.inventory{ id=true,
			{type="potion", subtype="potion", name="potion of lesser mana", ego_chance=-1000},
			{type="potion", subtype="potion", name="potion of lesser mana", ego_chance=-1000},
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Arcane Blade",
	desc = {
		"The Arcane Blade is a mage who spent some time studying the more pratical art of hitting people with pointy sticks.",
		"Arcane Blades may only cast spells from the most 'raw' magic schools (Arcane, Fire, Earth, Water and Air). Later on they can also learn Conveyance.",
		"In order to do melee combat most Arcane Blades will actually prefer to fight with their staff, as it requires Magic more than Strength to do damage.",
		"In the fields of melee combat they learn the use of shields and can later on train in various combat techniques.",
		"Their most important stats are: Magic and Dexterity",
	},
	stats = { mag=2, str=2, dex=2},
	talents_types = {
		["spell/arcane"]={true, 0.2},
		["spell/fire"]={true, 0.2},
		["spell/earth"]={true, 0.2},
		["spell/water"]={true, 0.2},
		["spell/air"]={true, 0.2},
		["spell/conveyance"]={false, 0.2},
		["technique/shield-offense"]={true, 0},
		["technique/shield-defense"]={true, 0},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={false, 0},
		["technique/combat-training"]={true, 0},
		["technique/magical-combat"]={true, 0},
		["cunning/survival"]={true, -0.1},
	},
	talents = {
		[ActorTalents.T_ARCANE_COMBAT] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_STONE_SKIN] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
	},
	copy = {
		max_life = 100,
		life_rating = 9,
		mana_rating = 8,
		stamina_rating = 8,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="shield", name="iron shield", autoreq=true},
			{type="armor", subtype="cloth", name="robe", autoreq=true},
		},
		resolvers.inventory{ id=true,
			{type="potion", subtype="potion", name="potion of lesser mana"},
			{type="potion", subtype="potion", name="potion of lesser mana"},
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Necromancer",
	desc = {
		"Their most important stats are: Magic and Willpower",
	},
	stats = { mag=3, wil=2, cun=1, },
	talents_types = {
		["spell/arcane"]={true, 0.3},
		["spell/fire"]={true, 0.3},
		["spell/earth"]={true, 0.3},
		["spell/water"]={true, 0.3},
		["spell/air"]={true, 0.3},
		["spell/phantasm"]={true, 0.3},
		["spell/temporal"]={false, 0.3},
		["spell/meta"]={false, 0.3},
		["spell/divination"]={true, 0.3},
		["spell/conveyance"]={true, 0.3},
		["spell/nature"]={true, 0.3},
		["spell/necromancy"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_ABSORB_SOUL] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_FREEZE] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
	},
	copy = {
		max_life = 80,
		life_rating = 7,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="robe", autoreq=true}
		},
		resolvers.inventory{ id=true,
			{type="potion", subtype="potion", name="potion of lesser mana"},
			{type="potion", subtype="potion", name="potion of lesser mana"},
		},
	},
}
