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
	name = "flaming ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.FIRE] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.64 end)},
	},
}
newEntity{
	name = "icy ", prefix=true,
	level_range = {15, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.ICE] = resolvers.mbonus_material(15, 4, function(e, v) return v * 0.7 end)},
	},
}
newEntity{
	name = "acidic ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.ACID] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.7 end)},
	},
}
newEntity{
	name = "shocking ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.7 end)},
	},
}
newEntity{
	name = "poisonous ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.POISON] = resolvers.mbonus_material(45, 6, function(e, v) return v * 0.5 end)},
	},
}

newEntity{
	name = "slime-covered ", prefix=true,
	level_range = {10, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.SLIME] = resolvers.mbonus_material(45, 6, function(e, v) return v * 0.9 end)},
	},
}

newEntity{
	name = " of accuracy", suffix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat={atk = resolvers.mbonus_material(20, 2, function(e, v) return v * 0.3 end)},
}

newEntity{
	name = "kinetic ", prefix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 6,
	combat={apr = resolvers.mbonus_material(15, 1, function(e, v) return v * 0.3 end)},
}

newEntity{
	name = "elemental ", prefix=true,
	level_range = {35, 50},
	rarity = 25,
	cost = 35,
	wielder = {
		melee_project={
			[DamageType.FIRE] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.7 end),
			[DamageType.ICE] = resolvers.mbonus_material(15, 4, function(e, v) return v * 0.7 end),
			[DamageType.ACID] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.7 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4, function(e, v) return v * 0.7 end),
		},
	},
}

newEntity{
	name = " of massacre", suffix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = resolvers.mbonus_material(25, 8, function(e, v) return v * 0.8 end), },
	},
}
