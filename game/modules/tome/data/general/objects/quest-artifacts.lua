-- Special items, used for quests

newEntity{
	unique = true, quest=true,
	slot = "MAINHAND",
	type = "weapon", subtype="staff",
	name = "Staff of Absorption",
	level_range = {30, 30},
	display = "\\", color=colors.VIOLET,
	encumber = 7,
	desc = [[Carved with runes of power this staff seems to have been made long ago. Yet it retains no signs of tarnishment.
	Light around it seems to dim and you can feel its tremoundous power simply by touching it.]],

	require = { stat = { mag=60 }, },
	combat = {
		dam = 30,
		apr = 4,
		atk = 20,
		dammod = {mag=1},
	},
	wielder = {
		combat_spellpower = 20,
		combat_spellcrit = 10,
	},
}
