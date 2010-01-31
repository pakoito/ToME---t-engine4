newEntity{ define_as = "TRAP_NATURAL_FOREST",
	type = "natural", subtype="forest", id_by_type=true, unided_name = "trap",
	display = '^',
	triggered = function(self, x, y, who)
		(self.src or who):project({type="hit"}, x, y, self.damtype, self.dam, self.particles and {type=self.particles})
		return true
	end,
}

newEntity{ base = "TRAP_NATURAL_FOREST",
	name = "sliding rock", auto_id = true,
	detect_power = 6, disarm_power = 16,
	rarity = 3, level_range = {1, 50},
	color=colors.UMBER,
	message = "@Target@ slides on a rock!",
	triggered = function(self, x, y, who)
		if who:checkHit(self.disarm_power + 5, who:combatPhysicalResist(), 0, 95, 15) and who:canBe("stun") then
			who:setEffect(who.EFF_STUNNED, 4, {})
		else
			game.logSeen(who, "%s resists!", who.name:capitalize())
		end
	end
}

newEntity{ base = "TRAP_NATURAL_FOREST",
	name = "poison vine", auto_id = true,
	detect_power = 8, disarm_power = 2,
	rarity = 3, level_range = {1, 50},
	color=colors.GREEN,
	message = "A poisonous vine strikes at @Target@!",
	dam = resolvers.mbonus(150, 15), damtype = DamageType.POISON,
}
