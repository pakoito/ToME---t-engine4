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
	name = " of fire resistance", suffix=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus(20, 10)},
	},
}
newEntity{
	name = " of cold resistance", suffix=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus(20, 10)},
	},
}
newEntity{
	name = " of acid resistance", suffix=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus(20, 10)},
	},
}
newEntity{
	name = " of lightning resistance", suffix=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.LIGHTNING] = resolvers.mbonus(20, 10)},
	},
}
newEntity{
	name = " of nature resistance", suffix=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 4,
	wielder = {
		resists={[DamageType.NATURE] = resolvers.mbonus(20, 10)},
	},
}


newEntity{
	name = "flaming ", prefix=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.FIRE] = resolvers.mbonus(7, 3)},
	},
}
newEntity{
	name = "icy ", prefix=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 10,
	wielder = {
		on_melee_hit={[DamageType.ICE] = resolvers.mbonus(4, 3)},
	},
}
newEntity{
	name = "acidic ", prefix=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.ACID] = resolvers.mbonus(7, 3)},
	},
}
newEntity{
	name = "shocking ", prefix=true,
	level_range = {15, 50},
	rarity = 8,
	cost = 8,
	wielder = {
		on_melee_hit={[DamageType.LIGHTNING] = resolvers.mbonus(7, 3)},
	},
}

newEntity{
	name = " of deflection", suffix=true,
	level_range = {10, 50},
	rarity = 15,
	cost = 20,
	wielder = {
		combat_def=resolvers.mbonus(15, 4),
	},
}

newEntity{
	name = " of resilience", suffix=true,
	level_range = {20, 50},
	rarity = 15,
	cost = 20,
	wielder = {
		max_life=resolvers.mbonus(100, 10),
	},
}
