load("/data/general/objects/staves.lua")
load("/data/general/objects/swords.lua")
load("/data/general/objects/shields.lua")
load("/data/general/objects/massive-armor.lua")

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
