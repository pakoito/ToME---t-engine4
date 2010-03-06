newEntity{
	define_as = "GENERAL_STORE",
	name = "general store",
	display = '1', color=colors.LIGHT_UMBER,
	store = {
		restock_after = 200,
		buy_percent = 10,
		min_fill = 40,
		max_fill = 60,
		filters = {
			{type="potion", id=true},
			{type="scroll", id=true},
		},
--		fixed = {
--		},
	},
}

newEntity{
	define_as = "POTION",
	name = "alchemist store",
	display = '4', color=colors.LIGHT_BLUE,
	store = {
		restock_after = 200,
		buy_percent = 10,
		min_fill = 40,
		max_fill = 60,
		filters = {
			{type="potion", id=true},
		},
	},
}

newEntity{
	define_as = "SCROLL",
	name = "scribe store",
	display = '5', color=colors.WHITE,
	store = {
		restock_after = 200,
		buy_percent = 10,
		min_fill = 40,
		max_fill = 60,
		filters = {
			{type="scroll", id=true},
		},
	},
}
