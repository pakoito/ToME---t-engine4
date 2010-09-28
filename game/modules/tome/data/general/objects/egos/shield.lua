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

--load("/data/general/objects/egos/charged-attack.lua")
--load("/data/general/objects/egos/charged-defensive.lua")
--load("/data/general/objects/egos/charged-utility.lua")

newEntity{
	name = " of fire resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus_material(20, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of cold resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus_material(20, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of acid resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus_material(20, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of lightning resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.LIGHTNING] = resolvers.mbonus_material(20, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of nature resistance", suffix=true, instant_resolve=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.NATURE] = resolvers.mbonus_material(20, 10, function(e, v) return v * 0.15 end)},
	},
}


newEntity{
	name = "flaming ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.FIRE] = resolvers.mbonus_material(7, 3, function(e, v) return v * 0.6 end)},
	},
}
newEntity{
	name = "icy ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 10,
	wielder = {
		on_melee_hit={[DamageType.ICE] = resolvers.mbonus_material(4, 3, function(e, v) return v * 0.7 end)},
	},
}
newEntity{
	name = "acidic ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.ACID] = resolvers.mbonus_material(7, 3, function(e, v) return v * 0.7 end)},
	},
}
newEntity{
	name = "shocking ", prefix=true, instant_resolve=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.LIGHTNING] = resolvers.mbonus_material(7, 3, function(e, v) return v * 0.7 end)},
	},
}

newEntity{
	name = " of deflection", suffix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 15,
	cost = 20,
	wielder = {
		combat_def=resolvers.mbonus_material(15, 4, function(e, v) return v * 1 end),
	},
}

newEntity{
	name = " of resilience", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	rarity = 15,
	cost = 20,
	wielder = {
		max_life=resolvers.mbonus_material(100, 10, function(e, v) return v * 0.1 end),
	},
}
