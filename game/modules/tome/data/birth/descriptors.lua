newBirthDescriptor{
	type = "base",
	name = "base",
	desc = {
	},
	talents = {},
	experience = 1.0,
	body = { INVEN = 1000, MAINHAND=1, OFFHAND=1, BODY=1 },

	copy = {
		equipment2 = resolvers.equip{
			{type="lite", subtype="lite", name="brass lantern"},
		},
	},
}

load("/data/birth/races.lua")
load("/data/birth/subraces.lua")
load("/data/birth/sexes.lua")
load("/data/birth/classes.lua")
