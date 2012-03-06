-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

newEntity{ define_as = "TRAP_ELEMENTAL",
	type = "elemental", id_by_type=true, unided_name = "trap",
	display = '^',
	pressure_trap = true,
	triggered = function(self, x, y, who)
		self:project({type="hit",x=x,y=y}, x, y, self.damtype, self.dam, self.particles and {type=self.particles})
		return true
	end,
}
newEntity{ define_as = "TRAP_ELEMENTAL_BLAST",
	type = "elemental", id_by_type=true, unided_name = "trap",
	display = '^',
	triggered = function(self, x, y, who)
		self:project({type="ball",x=x,y=y, radius=self.radius or 2}, x, y, self.damtype, self.dam, self.particles and {type=self.particles})
		return true
	end,
}

-------------------------------------------------------
-- Bolts
-------------------------------------------------------
newEntity{ base = "TRAP_ELEMENTAL",
	subtype = "acid",
	name = "acid trap", image = "trap/blast_acid01.png",
	detect_power = 6, disarm_power = 6,
	rarity = 3, level_range = {1, 30},
	color_r=40, color_g=220, color_b=0,
	message = "A stream of acid gushes onto @target@!",
	dam = resolvers.mbonus_level(100, 5), damtype = DamageType.ACID,
}
newEntity{ base = "TRAP_ELEMENTAL",
	subtype = "fire",
	name = "fire trap", image = "trap/blast_fire01.png",
	detect_power = 6, disarm_power = 6,
	rarity = 3, level_range = {1, 30},
	color_r=220, color_g=0, color_b=0,
	message = "A bolt of fire blasts onto @target@!",
	dam = resolvers.mbonus_level(140, 10), damtype = DamageType.FIREBURN,
}
newEntity{ base = "TRAP_ELEMENTAL",
	subtype = "cold",
	name = "ice trap", image = "trap/blast_ice01.png",
	detect_power = 6, disarm_power = 6,
	rarity = 3, level_range = {1, 30},
	color_r=150, color_g=150, color_b=220,
	message = "A bolt of ice blasts onto @target@!",
	dam = resolvers.mbonus_level(100, 5), damtype = DamageType.ICE,
	combatSpellpower = function(self) return self.disarm_power * 2 end,
}
newEntity{ base = "TRAP_ELEMENTAL",
	subtype = "lightning",
	name = "lightning trap", image = "trap/blast_lightning01.png",
	detect_power = 6, disarm_power = 6,
	rarity = 3, level_range = {1, 30},
	color_r=0, color_g=0, color_b=220,
	message = "A bolt of lightning fires onto @target@!",
	dam = resolvers.mbonus_level(100, 5), damtype = DamageType.LIGHTNING,
}
newEntity{ base = "TRAP_ELEMENTAL",
	subtype = "poison",
	name = "poison trap",
	detect_power = 6, disarm_power = 6, image = "trap/trap_poison_burst_01.png",
	rarity = 3, level_range = {1, 30},
	color_r=0, color_g=220, color_b=0,
	message = "A stream of poison gushes onto @target@!",
	dam = resolvers.mbonus_level(100, 5), damtype = DamageType.POISON,
	combatAttack = function(self) return self.dam end
}

-------------------------------------------------------
-- Blasts
-------------------------------------------------------
newEntity{ base = "TRAP_ELEMENTAL_BLAST",
	subtype = "acid",
	name = "acid blast trap",
	detect_power = 50, disarm_power = 50, image = "trap/trap_acid_blast_01.png",
	rarity = 3, level_range = {20, 50},
	color_r=40, color_g=220, color_b=0,
	message = "A stream of acid gushes onto @target@!",
	dam = resolvers.mbonus_level(250, 5), damtype = DamageType.ACID, radius = 2,
}
newEntity{ base = "TRAP_ELEMENTAL_BLAST",
	subtype = "fire",
	name = "fire blast trap", image = "trap/trap_fire_rune_01.png",
	detect_power = 50, disarm_power = 50,
	rarity = 3, level_range = {20, 50},
	color_r=220, color_g=0, color_b=0,
	message = "A bolt of fire fires onto @target@!",
	dam = resolvers.mbonus_level(300, 10), damtype = DamageType.FIREBURN, radius = 2,
}
newEntity{ base = "TRAP_ELEMENTAL_BLAST",
	subtype = "cold",
	name = "ice blast trap", image = "trap/trap_frost_rune_01.png",
	detect_power = 50, disarm_power = 50,
	rarity = 3, level_range = {20, 50},
	color_r=150, color_g=150, color_b=220,
	message = "A bolt of ice blasts onto @target@!",
	dam = resolvers.mbonus_level(250, 5), damtype = DamageType.ICE, radius = 2,
	combatSpellpower = function(self) return self.disarm_power * 2 end,
}
newEntity{ base = "TRAP_ELEMENTAL_BLAST",
	subtype = "lightning",
	name = "lightning blast trap", image = "trap/trap_lightning_rune_02.png",
	detect_power = 50, disarm_power = 50,
	rarity = 3, level_range = {20, 50},
	color_r=0, color_g=0, color_b=220,
	message = "A bolt of lightning fires onto @target@!",
	dam = resolvers.mbonus_level(250, 5), damtype = DamageType.LIGHTNING, radius = 2,
}
newEntity{ base = "TRAP_ELEMENTAL_BLAST", image = "trap/trap_poison_blast_01.png",
	subtype = "poison",
	name = "poison blast trap",
	detect_power = 50, disarm_power = 50,
	rarity = 3, level_range = {20, 50},
	color_r=0, color_g=220, color_b=0,
	message = "A stream of poison gushes onto @target@!",
	dam = resolvers.mbonus_level(250, 5), damtype = DamageType.POISON, radius = 2,
	combatAttack = function(self) return self.dam end
}
