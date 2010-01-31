newEntity{ define_as = "TRAP_ELEMENTAL",
	type = "elemental", id_by_type=true, unided_name = "trap",
	display = '^',
	triggered = function(self, x, y, who)
		(self.src or who):project({type="hit"}, x, y, self.damtype, self.dam, self.particles and {type=self.particles})
		return true
	end,
}
newEntity{ define_as = "TRAP_ELEMENTAL_BLAST",
	type = "elemental", id_by_type=true, unided_name = "trap",
	display = '^',
	triggered = function(self, x, y, who)
		(self.src or who):project({type="ball", radius=self.radius or 2}, x, y, self.damtype, self.dam, self.particles and {type=self.particles})
		return true
	end,
}

-------------------------------------------------------
-- Bolts
-------------------------------------------------------
newEntity{ base = "TRAP_ELEMENTAL",
	subtype = "acid",
	name = "acid trap",
	detect_power = 6, disarm_power = 6,
	rarity = 3, level_range = {1, 30},
	color_r=40, color_g=220, color_b=0,
	message = "A stream of acid gushes onto @target@!",
	dam = resolvers.mbonus(150, 5), damtype = DamageType.ACID,
}
newEntity{ base = "TRAP_ELEMENTAL",
	subtype = "fire",
	name = "fire trap",
	detect_power = 6, disarm_power = 6,
	rarity = 3, level_range = {1, 30},
	color_r=220, color_g=0, color_b=0,
	message = "A bolt of fire fires onto @target@!",
	dam = resolvers.mbonus(180, 10), damtype = DamageType.FIREBURN,
}
newEntity{ base = "TRAP_ELEMENTAL",
	subtype = "cold",
	name = "ice trap",
	detect_power = 6, disarm_power = 6,
	rarity = 3, level_range = {1, 30},
	color_r=150, color_g=150, color_b=220,
	message = "A bolt of ice gushes onto @target@!",
	dam = resolvers.mbonus(150, 5), damtype = DamageType.ICE,
}
newEntity{ base = "TRAP_ELEMENTAL",
	subtype = "lightning",
	name = "lightning trap",
	detect_power = 6, disarm_power = 6,
	rarity = 3, level_range = {1, 30},
	color_r=0, color_g=0, color_b=220,
	message = "A bolt of lightning fires onto @target@!",
	dam = resolvers.mbonus(150, 5), damtype = DamageType.LIGHTNING,
}
newEntity{ base = "TRAP_ELEMENTAL",
	subtype = "poison",
	name = "poison trap",
	detect_power = 6, disarm_power = 6,
	rarity = 3, level_range = {1, 30},
	color_r=0, color_g=220, color_b=0,
	message = "A stream of poison gushes onto @target@!",
	dam = resolvers.mbonus(150, 5), damtype = DamageType.POISON,
}

-------------------------------------------------------
-- Blasts
-------------------------------------------------------
newEntity{ base = "TRAP_ELEMENTAL_BLAST",
	subtype = "acid",
	name = "acid blast trap",
	detect_power = 50, disarm_power = 50,
	rarity = 3, level_range = {20, 50},
	color_r=40, color_g=220, color_b=0,
	message = "A stream of acid gushes onto @target@!",
	dam = resolvers.mbonus(250, 5), damtype = DamageType.ACID, radius = 2,
}
newEntity{ base = "TRAP_ELEMENTAL_BLAST",
	subtype = "fire",
	name = "fire blast trap",
	detect_power = 50, disarm_power = 50,
	rarity = 3, level_range = {20, 50},
	color_r=220, color_g=0, color_b=0,
	message = "A bolt of fire fires onto @target@!",
	dam = resolvers.mbonus(300, 10), damtype = DamageType.FIREBURN, radius = 2,
}
newEntity{ base = "TRAP_ELEMENTAL_BLAST",
	subtype = "cold",
	name = "ice blast trap",
	detect_power = 50, disarm_power = 50,
	rarity = 3, level_range = {20, 50},
	color_r=150, color_g=150, color_b=220,
	message = "A bolt of ice gushes onto @target@!",
	dam = resolvers.mbonus(250, 5), damtype = DamageType.ICE, radius = 2,
}
newEntity{ base = "TRAP_ELEMENTAL_BLAST",
	subtype = "lightning",
	name = "lightning blast trap",
	detect_power = 50, disarm_power = 50,
	rarity = 3, level_range = {20, 50},
	color_r=0, color_g=0, color_b=220,
	message = "A bolt of lightning fires onto @target@!",
	dam = resolvers.mbonus(250, 5), damtype = DamageType.LIGHTNING, radius = 2,
}
newEntity{ base = "TRAP_ELEMENTAL_BLAST",
	subtype = "poison",
	name = "poison blast trap",
	detect_power = 50, disarm_power = 50,
	rarity = 3, level_range = {20, 50},
	color_r=0, color_g=220, color_b=0,
	message = "A stream of poison gushes onto @target@!",
	dam = resolvers.mbonus(250, 5), damtype = DamageType.POISON, radius = 2,
}
