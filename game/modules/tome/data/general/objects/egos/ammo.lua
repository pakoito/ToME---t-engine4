-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

local Talents = require("engine.interface.ActorTalents")

newEntity{
	power_source = {technique=true},
	name = "quick-loading ", prefix=true, instant_resolve=true,
	keywords = {quick=true},
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		learn_talent = {
			[Talents.T_RELOAD] = resolvers.mbonus_material("learn_talent"),
		}
	},
}

newEntity{
	power_source = {technique=true},
	name = "high-capacity ", prefix=true, instant_resolve=true,
	keywords = {capacity=true},
	level_range = {1, 50},
	rarity = 5,
	combat = {
		capacity = resolvers.mbonus_material("capacity"),
	},
	resolvers.genericlast(function(e) 
		e.combat.shots_left = e.combat.capacity end),
}

newEntity{
	power_source = {arcane=true},
	name = "self-loading ", prefix=true, instant_resolve=true,
	keywords = {self=true},
	level_range = {1, 50},
	rarity = 5,
	combat = {
		ammo_regen = resolvers.mbonus_material("ammo_regen"),
	},
	resolvers.genericlast(function(e) 
		e.combat.ammo_every = 6 - e.combat.ammo_regen 
	end),
}

newEntity{
	power_source = {technique=true},
	name = "battle-ranger's ", prefix=true, instant_resolve=true,
	keywords = {ranger=true},
	level_range = {1, 50},
	rarity = 5,
	greater_ego = 1,
	combat = {
		capacity = resolvers.mbonus_material("capacity"),
	},
	wielder = {
		learn_talent = {
			[Talents.T_RELOAD] = resolvers.mbonus_material("learn_talent"),
		}
	},
	resolvers.genericlast(function(e) 
		e.combat.shots_left = e.combat.capacity end),
}

newEntity{
	power_source = {arcane=true},
	name = "enchanted ", prefix=true, instant_resolve=true,
	keywords = {enchanted=true},
	level_range = {1, 50},
	rarity = 5,
	greater_ego = 1,
	combat = {
		ammo_regen = resolvers.mbonus_material("ammo_regen"),
	},
	wielder = {
		learn_talent = {
			[Talents.T_RELOAD] = resolvers.mbonus_material("learn_talent"),
		}
	},
	resolvers.genericlast(function(e) 
		e.combat.ammo_every = 6 - e.combat.ammo_regen 
	end),
}

newEntity{
	power_source = {arcane=true},
	name = "sentry's ", prefix=true, instant_resolve=true,
	keywords = {sentry=true},
	level_range = {1, 50},
	rarity = 5,
	greater_ego = 1,
	combat = {
		ammo_regen = resolvers.mbonus_material("ammo_regen"),
		capacity = resolvers.mbonus_material("capacity"),
	},
	resolvers.genericlast(function(e) 
		e.combat.ammo_every = 6 - e.combat.ammo_regen 
	end),
	resolvers.genericlast(function(e) 
		e.combat.shots_left = e.combat.capacity end),
}

newEntity{
	power_source = {nature=true},
	name = " of fire", suffix=true, instant_resolve=true,
	keywords = {fire=true},
	level_range = {1, 50},
	rarity = 5,
	combat = {
		ranged_project={[DamageType.FIRE] = resolvers.mbonus_material("ranged_project", 1)},
	},
}
newEntity{
	power_source = {nature=true},
	name = " of ice", suffix=true, instant_resolve=true,
	keywords = {ice=true},
	level_range = {15, 50},
	rarity = 5,
	combat = {
		ranged_project={[DamageType.ICE] = resolvers.mbonus_material("ranged_project", 0.5)},
	},
}
newEntity{
	power_source = {nature=true},
	name = " of acid", suffix=true, instant_resolve=true,
	keywords = {cunning=true},
	level_range = {1, 50},
	rarity = 5,
	combat = {
		ranged_project={[DamageType.ACID] = resolvers.mbonus_material("ranged_project", 1)},
	},
}
newEntity{
	power_source = {nature=true},
	name = " of lightning", suffix=true, instant_resolve=true,
	keywords = {lightning=true},
	level_range = {1, 50},
	rarity = 5,
	combat = {
		ranged_project={[DamageType.LIGHTNING] = resolvers.mbonus_material("ranged_project", 1)},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of slime", suffix=true, instant_resolve=true,
	keywords = {slime=true},
	level_range = {10, 50},
	rarity = 5,
	combat = {
		ranged_project={[DamageType.SLIME] = resolvers.mbonus_material("ranged_project", 0.5)},
	},
}

newEntity{
	power_source = {technique=true},
	name = " of accuracy", suffix=true, instant_resolve=true,
	keywords = {accuracy=true},
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat = {max_acc = resolvers.mbonus_material("max_acc")},
}

newEntity{
	power_source = {nature=true},
	name = " of the elements", suffix=true, instant_resolve=true,
	keywords = {elements=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 25,
	cost = 35,
	combat = {
		ranged_project={
			[DamageType.FIRE] = resolvers.mbonus_material("ranged_project", 0.5),
			[DamageType.ICE] = resolvers.mbonus_material("ranged_project", 0.5),
			[DamageType.ACID] = resolvers.mbonus_material("ranged_project", 0.5),
			[DamageType.LIGHTNING] = resolvers.mbonus_material("ranged_project", 0.5),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of the wind", suffix=true, instant_resolve=true,
	keywords = {wind=true},
	level_range = {10, 50},
	rarity = 7,
	combat = {
		travel_speed = 200,
	},
}

newEntity{
	power_source = {technique=true},
	name = " of annihilation", suffix=true, instant_resolve=true,
	keywords = {annihilation=true},
	level_range = {1, 50},
	greater_ego = 1,
	cost = 1,
	rarity = 15,
	combat = {
		dam = resolvers.mbonus_material("dam", 4),
		max_acc = resolvers.mbonus_material("max_acc", 3),
		travel_speed = 200,
	},
	-- Powerful but comes in a small quiver/pouch
	resolvers.generic(function(e)
		e.combat.capacity = math.ceil(e.combat.capacity/4)
		e.combat.shots_left = e.combat.capacity
	end),
}

newEntity{
	power_source = {arcane=true},
	name = " of corruption", suffix=true, instant_resolve=true,
	keywords = {corruption=true},
	level_range = {35, 50},
	greater_ego = 1,
	rarity = 20,
	cost = 35,
	combat = {
		ranged_project={
			[DamageType.BLIGHT] = resolvers.mbonus_material("ranged_project", 1, true),
			[DamageType.DARKNESS] = resolvers.mbonus_material("ranged_project", 1, true),
		},
	},
}

newEntity{
	power_source = {arcane=true},
	name = " of paradox", suffix=true, instant_resolve=true,
	keywords = {paradox=true},
	level_range = {1, 50},
	greater_ego = 1,
	rarity = 15,
	cost = 30,
	combat = {
		ranged_project = {
			[DamageType.TEMPORAL] = resolvers.mbonus_material("ranged_project", 2, true),
			[DamageType.RANDOM_CONFUSION] = resolvers.mbonus_material("ranged_project", 1, true),
		},
	},
}

newEntity{
	power_source = {nature=true},
	name = " of sunrise", suffix=true,
	keywords = {sunrise=true},
	level_range = {1, 50},
	greater_ego = 1,
	cost = 30,
	rarity = 15,
	combat = {
		tg_type = "beam",
		damtype = DamageType.LIGHT,
		travel_speed = 300,
		lite = true,
	},
	-- Powerful but comes in a small quiver/pouch
	resolvers.generic(function(e)
		e.combat.capacity = math.ceil(e.combat.capacity/4)
		e.combat.shots_left = e.combat.capacity
	end),
}
