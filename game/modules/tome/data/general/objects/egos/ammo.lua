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

newEntity{
	name = "flaming ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		ranged_project={[DamageType.FIRE] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.1 * 0.64 end)},
	},
}
newEntity{
	name = "icy ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 5,
	wielder = {
		ranged_project={[DamageType.ICE] = resolvers.mbonus_material(15, 4, function(e, v) return v * 0.1 * 0.7 end)},
	},
}
newEntity{
	name = "acidic ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		ranged_project={[DamageType.ACID] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.1 * 0.7 end)},
	},
}
newEntity{
	name = "shocking ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		ranged_project={[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.1 * 0.7 end)},
	},
}
newEntity{
	name = "poisonous ", prefix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		ranged_project={[DamageType.POISON] = resolvers.mbonus_material(45, 6, function(e, v) return v * 0.1 * 0.5 end)},
	},
}

newEntity{
	name = "slime-covered ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 5,
	wielder = {
		ranged_project={[DamageType.SLIME] = resolvers.mbonus_material(45, 6, function(e, v) return v * 0.1 * 0.9 end)},
	},
}

newEntity{
	name = "elemental ", prefix=true, instant_resolve=true,
	level_range = {35, 50},
	greater_ego = true,
	rarity = 25,
	cost = 35,
	wielder = {
		ranged_project={
			[DamageType.FIRE] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.1 * 0.7 * 0.3 end),
			[DamageType.ICE] = resolvers.mbonus_material(15, 4, function(e, v) return v * 0.1 * 0.7 * 0.3 end),
			[DamageType.ACID] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.1 * 0.7 * 0.3 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.1 * 0.7 * 0.3 end),
		},
	},
}

newEntity{
	name = " of the wind", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 7,
	combat = {
		travel_speed = 200,
		atk = resolvers.mbonus_material(10, 3, function(e, v) return v * 0.1 * 0.5 end),
	},
}
