newBirthDescriptor{
	type = "base",
	name = "base",
	desc = {
	},
	talents = {},
	experience = 1.0,
	body = { INVEN = 1000, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },

	copy = {
		money = 10,
		resolvers.equip{ id=true,
			{type="lite", subtype="lite", name="brass lantern"},
		},
		resolvers.inventory{ id=true,
			{type="potion", subtype="potion", name="potion of lesser healing"},
			{type="potion", subtype="potion", name="potion of lesser healing"},
			{type="potion", subtype="potion", name="potion of lesser healing"},
		},
		resolvers.generic(function(e)
			e.hotkey[9] = {"inventory", "potion of lesser healing"}
		end),
	},
}

-- Races
load("/data/birth/races/human.lua")
load("/data/birth/races/elf.lua")
load("/data/birth/races/hobbit.lua")
load("/data/birth/races/dwarf.lua")

-- Sexes
load("/data/birth/sexes.lua")

-- Classes
load("/data/birth/warrior.lua")
load("/data/birth/rogue.lua")
load("/data/birth/archer.lua")
load("/data/birth/mage.lua")
