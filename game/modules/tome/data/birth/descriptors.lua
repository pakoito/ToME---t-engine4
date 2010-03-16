newBirthDescriptor{
	type = "base",
	name = "base",
	desc = {
	},
	descriptor_choices =
	{
		race =
		{
			__ALL__ = "never",
			Human = "allow",
			Elf = "allow",
			Dwarf = "allow",
			Hobbit = "allow",
--			Orc = config.settings.tome.allow_evil and "allow" or "never",
--			Troll = config.settings.tome.allow_evil and "allow" or "never",
--			Spider = config.settings.tome.allow_evil and "allow" or "never",
		},
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
			{type="potion", subtype="potion", name="potion of lesser healing", ego_chance=-1000},
			{type="potion", subtype="potion", name="potion of lesser healing", ego_chance=-1000},
			{type="potion", subtype="potion", name="potion of lesser healing", ego_chance=-1000},
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
load("/data/birth/races/orc.lua")
load("/data/birth/races/troll.lua")
--load("/data/birth/races/spider.lua")

-- Sexes
load("/data/birth/sexes.lua")

-- Classes
load("/data/birth/classes/warrior.lua")
load("/data/birth/classes/archer.lua")
load("/data/birth/classes/rogue.lua")
load("/data/birth/classes/mage.lua")
load("/data/birth/classes/wilder.lua")
