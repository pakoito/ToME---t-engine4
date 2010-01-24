newBirthDescriptor{
	type = "base",
	name = "base",
	desc = {
	},
	talents = {},
	experience = 1.0,
	body = { INVEN = 1000, MAINHAND=1, OFFHAND=1, BODY=1 },

	copy = {
		resolvers.equip{ id=true,
			{type="lite", subtype="lite", name="brass lantern"},
		},
		resolvers.inventory{ id=true,
			{type="potion", subtype="potion", name="potion of lesser healing"},
			{type="potion", subtype="potion", name="potion of lesser healing"},
			{type="potion", subtype="potion", name="potion of lesser healing"},
		},
	},
}

load("/data/birth/races/human.lua")
load("/data/birth/races/elf.lua")
load("/data/birth/races/hobbit.lua")
load("/data/birth/races/dwarf.lua")
load("/data/birth/sexes.lua")
load("/data/birth/classes.lua")
