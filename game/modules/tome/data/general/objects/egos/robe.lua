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
	cost = 6,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of cold resistance", suffix=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of acid resistance", suffix=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of lightning resistance", suffix=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.LIGHTNING] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}
newEntity{
	name = " of nature resistance", suffix=true,
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.NATURE] = resolvers.mbonus_material(30, 10, function(e, v) return v * 0.15 end)},
	},
}

newEntity{
	name = "shimmering ", prefix=true,
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		max_mana = resolvers.mbonus_material(100, 10, function(e, v) return v * 0.1 end),
	},
}

newEntity{
	name = "slimy ", prefix=true,
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		on_melee_hit={[DamageType.SLIME] = resolvers.mbonus_material(7, 3, function(e, v) return v * 1 end)},
	},
}

newEntity{
	name = " of power", suffix=true,
	level_range = {20, 50},
	rarity = 15,
	cost = 15,
	wielder = {
		inc_damage = {
			[DamageType.ARCANE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.FIRE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.COLD] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.ACID] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.NATURE] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.BLIGHT] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(15, 5, function(e, v) return v * 0.25 end),
		},
		combat_spellpower = 4,
	},
}
