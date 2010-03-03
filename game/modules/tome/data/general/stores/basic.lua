newEntity{
	define_as = "GENERAL_STORE",
	name = "general store",
	display = '1', color=colors.LIGHT_UMBER,
	store = {
		restock_after = 200,
		buy_percent = 10,
		min_fill = 10,
		max_fill = 20,
		filters = {
			{type="potion", id=true},
			{type="scroll", id=true},
		},
--		fixed = {
--		},
	},
}
