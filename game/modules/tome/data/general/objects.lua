load("/data/general/staves.lua")
load("/data/general/swords.lua")
load("/data/general/shields.lua")
load("/data/general/massive-armor.lua")

newEntity{
	name = "& Staff of Olorin",
	type = "weapon",
	display = "/", color_r=255, color_b=255,
	level_range = {10,10},
	rarity = 15,
	encumber = 3,
	unique = "STAFF_OLORIN",
	combat = {
		dam = 3,
		atk = 1,
		apr = 0,
		dammod = {wil=1},
	},
	wielder = {
		stats = {mag=3, wil=2},
	}
}
