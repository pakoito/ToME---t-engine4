newEntity{
	define_as = "BASE_MONEY",
	type = "money", subtype="money",
	display = "$", color=colors.YELLOW,
	encumber = 0,
	rarity = 5,
	identified = true,
	desc = [[All that glisters is not gold, all that is gold does not glitter.]],
	on_prepickup = function(self, who, id)
		who.money = who.money + self.money_value / 10
		-- Remove from the map
		game.level.map:removeObject(who.x, who.y, id)
		return true
	end,
}

newEntity{ base = "BASE_MONEY",
	name = "gold pieces",
	add_name = " (#MONEY#)",
	level_range = {1, 50},
	money_value = resolvers.rngavg(1, 20),
}
