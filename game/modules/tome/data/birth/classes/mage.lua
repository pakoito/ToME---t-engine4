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
		"Mages are the wielders of the arcane powers, able to cast powerful spells of destruction or to heal their wounds with nothing but a thought.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			Archmage = function() return profile.mod.allow_build.mage and "allow" or "disallow" end,
			Alchemist = "allow",
		},
	},
	copy = {
		-- All mages are of angolwen faction
		faction = "angolwen",
		mana_regen = 0.5,
		mana_rating = 7,
		resolvers.generic(function(e)
			e.hotkey[10] = {"inventory", "potion of lesser mana"}
		end),
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Archmage",
	desc = {
		"An Archmage devotes their whole life to the study of magic above anything else.",
		"Most archmagi lack basic skills that others take for granted (like general fighting sense), but they make up for it by their raw magical power.",
		"Archmagi know all schools of magic but the more intricate (Temporal and Meta) from the start. They however usually refuse to have anything to do with Necromancy.",
		"All archmagi have been trained in the secret town of Angolwen and posses a unique spell to teleport to it directly.",
		"Their most important stats are: Magic and Willpower",
	},
	stats = { mag=5, wil=3, cun=1, },
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
		["spell/enhancement"]={true, 0},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
		[ActorTalents.T_ARCANE_POWER] = 1,
		[ActorTalents.T_FLAME] = 1,
		[ActorTalents.T_LIGHTNING] = 1,
		[ActorTalents.T_PHASE_DOOR] = 1,
		[ActorTalents.T_TELEPORT_ANGOLWEN]=1,
	},
	copy = {
		max_life = 90,
		life_rating = 10,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="cloth", name="robe", autoreq=true}
			{type="alchemist-gem", subtype="black", autoreq=true},
		},
		resolvers.inventory{ id=true,
			{type="potion", subtype="potion", name="potion of lesser mana", ego_chance=-1000},
			{type="potion", subtype="potion", name="potion of lesser mana", ego_chance=-1000},
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Alchemist",
	desc = {
		"An Alchemist is a dabbler in magic, while 'true' magic is thought to have been lost with the departure of Gandalf and the fall of Saruman.",
		"Alchemists have an empirical knowledge of magic, which they can not use directly but through focuses.",
		"A focus is usualy a gem which they can imbue with power to throw at their foes, exploding in fires, acid, ...",
		"Alchemists are also known for their golem craft and are usualy accompagnied by such a construct which acts as a body guard.",
		"Their most important stats are: Magic and Willpower",
	},
	stats = { mag=5, wil=3, cun=1, },
	talents_types = {
		["spell/alchemy"]={true, 0.3},
		["spell/infusion"]={true, 0.3},
		["spell/golemancy"]={true, 0.3},
		["spell/advanced-golemancy"]={true, 0.3},
		["spell/gemology"]={true, 0.3},
		["spell/herbalism"]={true, 0.3},
		["cunning/survival"]={false, -0.1},
	},
	talents = {
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
