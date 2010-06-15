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
		melee_project={[DamageType.FIRE] = resolvers.mbonus_material(25, 4)},
	},
}
newEntity{
	name = "icy ", prefix=true,
	level_range = {15, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.ICE] = resolvers.mbonus_material(15, 4)},
	},
}
newEntity{
	name = "acidic ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.ACID] = resolvers.mbonus_material(25, 4)},
	},
}
newEntity{
	name = "shocking ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4)},
	},
}
newEntity{
	name = "poisonous ", prefix=true,
	level_range = {1, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.POISON] = resolvers.mbonus_material(45, 6)},
	},
}

newEntity{
	name = "slime-covered ", prefix=true,
	level_range = {10, 50},
	rarity = 5,
	wielder = {
		melee_project={[DamageType.SLIME] = resolvers.mbonus_material(45, 6)},
	},
}

newEntity{
	name = " of accuracy", suffix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	combat={atk = resolvers.mbonus_material(20, 2)},
}

newEntity{
	name = "kinetic ", prefix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 6,
	combat={apr = resolvers.mbonus_material(15, 1)},
}

newEntity{
	name = "elemental ", prefix=true,
	level_range = {35, 50},
	rarity = 25,
	cost = 35,
	wielder = {
		melee_project={
			[DamageType.FIRE] = resolvers.mbonus_material(25, 4),
			[DamageType.ICE] = resolvers.mbonus_material(15, 4),
			[DamageType.ACID] = resolvers.mbonus_material(25, 4),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(25, 4),
		},
	},
}

newEntity{
	name = " of massacre", suffix=true,
	level_range = {1, 50},
	rarity = 3,
	cost = 4,
	wielder = {
		inc_damage={ [DamageType.PHYSICAL] = resolvers.mbonus_material(25, 8), },
	},
}
