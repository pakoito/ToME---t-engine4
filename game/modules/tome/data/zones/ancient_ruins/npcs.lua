return {

{
	name = "dragon of death",
	display = "D", color_r=255,
	level_range = {1, 10}, exp_worth = 1,
	autolevel = "warrior",
	max_life = 20,
	max_mana = 1000,
	max_stamina = 1000,
	energy = { mod=0.5 },
	has_blood = true,
	stats = { str=15, dex=8, mag=12, },
	combat = { dam=8, atk=10, apr=2, def=4, armor=6},
},
{
	name = "baby dragon",
	display = "d", color_r=128,
	faction = "poorsods",
	level_range = {1, 4}, exp_worth = 1,
	autolevel = "caster",
	max_life = 30,
	max_mana = 1000,
	max_stamina = 1000,
	energy = { mod=0.3 },
	has_blood = {nb=3, color={50,255,120}},
	combat = { dam=5, atk=6, def=2, apr=1, armor=2},
},

}