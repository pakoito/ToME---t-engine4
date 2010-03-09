newEntity{
	define_as = "BASE_GREATMAUL",
	slot = "MAINHAND",
	slot_forbid = "OFFHAND",
	type = "weapon", subtype="greatmaul",
	add_name = " (#COMBAT#)",
	display = "\\", color=colors.SLATE,
	encumber = 5,
	rarity = 3,
	combat = { talented = "mace", damrange = 1.5 },
	desc = [[Massive two-handed maul.]],
	twohanded = true,
	egos = "/data/general/objects/egos/weapon.lua", egos_chance = resolvers.mbonus(40, 5),
}
