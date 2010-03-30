newEntity{
	define_as = "GENERAL_STORE",
	name = "general store",
	display = '1', color=colors.LIGHT_UMBER,
	store = {
		restock_after = 1000,
		empty_before_restock = true,
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
	define_as = "ARMOR",
	name = "armour smith",
	display = '2', color=colors.UMBER,
	store = {
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		min_fill = 10,
		max_fill = 20,
		filters = {
			{type="armor", id=true},
		},
	},
}

newEntity{
	define_as = "WEAPON",
	name = "weapon mith",
	display = '3', color=colors.UMBER,
	store = {
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		min_fill = 10,
		max_fill = 20,
		filters = {
			{type="weapon", id=true},
			{type="ammo", id=true},
		},
	},
}

newEntity{
	define_as = "POTION",
	name = "alchemist store",
	display = '4', color=colors.LIGHT_BLUE,
	store = {
		restock_after = 1000,
		empty_before_restock = true,
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
		restock_after = 1000,
		empty_before_restock = true,
		buy_percent = 10,
		min_fill = 40,
		max_fill = 60,
		filters = {
			{type="scroll", id=true},
		},
	},
}
