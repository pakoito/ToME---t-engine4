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
	name = "Tutorial Adventurer",
	desc = {
		"Adventurers have a generic talents-set to teach to young ones.",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "disallow",
			["Tutorial Adventurer"] = "allow",
		},
	},
	copy = {
		max_life = 120,
		life_rating = 12,
		mana_regen = 0.2,
		life_regen = 1,
		mana_rating = 7,
		resolvers.generic(function(e)
			e.hotkey[10] = {"inventory", "potion of lesser mana"}
		end),
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Tutorial Adventurer",
	desc = {
		"Adventurers have a generic talents-set to teach to young ones.",
	},
	stats = { str=10, con=5, dex=5, mag=10, wil=5, cun=5 },
	talents_types = {
		["technique/shield-offense"]={true, 0.3},
		["technique/shield-defense"]={true, 0.3},
		["technique/combat-training"]={true, 0.3},
		["cunning/survival"]={true, 0.3},
		["spell/fire"]={true, 0.3},
		["spell/air"]={true, 0.3},
		["spell/arcane"]={true, 0.3},
	},
	talents = {
		[ActorTalents.T_SHIELD_PUMMEL] = 2,
		[ActorTalents.T_REPULSION] = 2,
		[ActorTalents.T_WEAPON_COMBAT] = 2,
		[ActorTalents.T_HEAVY_ARMOUR_TRAINING] = 2,
		[ActorTalents.T_FLAME] = 2,
		[ActorTalents.T_LIGHTNING] = 2,
		[ActorTalents.T_ARCANE_POWER] = 2,
	},
	copy = {
		resolvers.equip{ id=true,
			{type="weapon", subtype="longsword", name="iron longsword", autoreq=true},
			{type="armor", subtype="shield", name="iron shield", autoreq=true},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true}
		},
		resolvers.inventory{ id=true,
			{type="potion", subtype="potion", name="potion of lesser mana", ego_chance=-1000},
			{type="potion", subtype="potion", name="potion of lesser mana", ego_chance=-1000},
		},
	},
}
