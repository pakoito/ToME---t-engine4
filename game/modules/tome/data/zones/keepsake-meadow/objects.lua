-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

load("/data/general/objects/objects-maj-eyal.lua")

newEntity{ base = "BASE_LORE",
	define_as = "BANDERS_NOTES",
	name = "folded up piece of paper",
	lore="keepsake-banders-notes",
	desc = [[A folded up piece of paper with a few notes written on it.]],
	rarity = false,
	encumberance = 0,
}

newEntity{
	define_as = "IRON_ACORN_BASIC",
	name = "Iron Acorn",
	type = "misc", subtype="trinket",
	display = "*", color=colors.SLATE, image = "object/iron_acorn.png",
	quest=true,
	unique = true,
	identified = true,
	rarity = false,
	power_source = {technique=true},
	cost = 1,
	material_level = 1,
	encumber = 0,
	not_in_stores = true,
	desc = [[A small acorn, crafted crudely out of iron.]],
	on_pickup = function(self, who)
		if who.player then
			who:hasQuest("keepsake"):on_pickup_acorn(who)
		end
	end,
	on_drop = function(self, who)
		if who.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

newEntity{
	define_as = "IRON_ACORN_GOOD",
	name = "Iron Acorn",
	type = "misc", subtype="trinket",
	display = "*", color=colors.SLATE, image = "object/iron_acorn.png",
	quest=true,
	unique = true,
	identified = true,
	rarity = false,
	power_source = {psionic=true},
	cost = 1,
	material_level = 1,
	encumber = 0,
	not_in_stores = true,
	desc = [[A small acorn, crafted crudely out of iron. It once belonged to Bander, but now it is yours. You find having the acorn helps to anchor your mind and prepare you for the trials ahead.]],
	carrier = {
		resists={[DamageType.MIND] = 30, [DamageType.PHYSICAL] = 8,},
		combat_mindpower = 15,
		max_life = 40
	},
	on_drop = function(self, who)
		if who.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

newEntity{
	define_as = "IRON_ACORN_EVIL",
	name = "Cold Iron Acorn",
	type = "misc", subtype="trinket",
	display = "*", color=colors.SLATE, image = "object/iron_acorn.png",
	quest=true,
	unique = true,
	identified = true,
	rarity = false,
	power_source = {psionic=true},
	cost = 1,
	material_level = 1,
	encumber = 0,
	not_in_stores = true,
	desc = [[A small acorn, crafted crudely out of iron. It once belonged to Bander, but now it is yours. The acorn serves as a reminder of who and what you are.]],
	carrier = {
		resists={[DamageType.MIND] = 30,},
		inc_damage = { [DamageType.PHYSICAL] = 12 },
		movement_speed = 0.2
	},
	on_drop = function(self, who)
		if who.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

for i = 1, 4 do
	newEntity{ base = "BASE_LORE",
		define_as = "KYLESS_JOURNAL_"..i,
		name = "journal page", lore="keepsake-kyless-journal-"..i,
		desc = [[A page containing an entry from Kyless' journal.]],
		rarity = false,
		is_magic_device = false,
		encumberance = 0,
	}
end

newEntity{
	define_as = "KYLESS_BOOK",
	name = "Kyless' Book",
	type = "misc", subtype="trinket",
	display = "%", color=colors.SLATE, image = "object/spellbook.png",
	quest=true,
	unique = true,
	identified = true,
	rarity = false,
	power_source = {psionic=true},
	cost = 1,
	material_level = 1,
	encumber = 5,
	not_in_stores = true,
	desc = [[This was the book that gave power to Kyless and eventually lead to his doom. The book has a simple appearance: bound in leather with no markings on the cover. All of the pages are blank.]],
}


