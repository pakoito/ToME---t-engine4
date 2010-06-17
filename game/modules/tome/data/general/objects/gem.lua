-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

newEntity{
	define_as = "BASE_GEM",
	type = "gem", subtype="white",
	display = "*", color=colors.YELLOW,
	encumber = 0,
	identified = true,
	stacking = true,
	desc = [[Gems can be sold for money or used in arcane rituals.]],
}

local function newGem(name, cost, rarity, color, min_level, max_level)
	newEntity{ base = "BASE_GEM",
		name = name:lower(), subtype = color,
		color = colors[color:upper()],
		level_range = {min_level, max_level},
		rarity = rarity, cost = cost,
	}
end

newGem("Diamond",5,18,"white",40,50)
newGem("Pearl",5,18,"white",40,50)
newGem("Moonstone",5,18,"white",40,50)
newGem("Fire Opal",5,18,"red",40,50)
newGem("Bloodstone",5,18,"red",40,50)
newGem("Ruby",4,16,"red",30,40)
newGem("Amber",4,16,"yellow",30,40)
newGem("Turquoise",4,16,"green",30,40)
newGem("Jade",4,16,"green",30,40)
newGem("Sapphire",4,16,"blue",30,40)
newGem("Quartz",3,12,"white",20,30)
newGem("Emerald",3,12,"green",20,30)
newGem("Lapis Lazuli",3,12,"blue",20,30)
newGem("Garnets",3,12,"red",20,30)
newGem("Onyx",3,12,"black",20,30)
newGem("Amethyst",2,10,"violet",10,20)
newGem("Opal",2,10,"blue",10,20)
newGem("Topaz",2,10,"blue",10,20)
newGem("Aquamarine",2,10,"blue",10,20)
newGem("Ametrine",1,8,"yellow",1,10)
newGem("Zircon",1,8,"yellow",1,10)
newGem("Spinel",1,8,"green",1,10)
newGem("Citrine",1,8,"yellow",1,10)
newGem("Agate",1,8,"black",1,10)
