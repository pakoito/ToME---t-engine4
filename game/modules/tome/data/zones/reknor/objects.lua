-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

newEntity{ base = "BASE_SCROLL", define_as = "NOTE_FROM_LAST_HOPE",
	name = "Sealed Scroll of Last Hope", identified=true, unique=true, no_unique_lore=true,
	image = "object/letter1.png",
	fire_proof = true,

	use_simple = { name="open the seal and read the message", use = function(self, who)
		game:registerDialog(require("engine.dialogs.ShowText").new(self:getName{do_color=true}, "message-last-hope", {playername=who.name}, game.w * 0.6))
		return {used=true, id=true}
	end}
}

newEntity{ base = "BASE_GEM",
	define_as = "RESONATING_DIAMOND_WEST",
	name = "Resonating Diamond", color=colors.VIOLET, quest=true, unique="Resonating Diamond West", identified=true, no_unique_lore=true,
	image = "object/artifact/resonating_diamond.png",
	material_level = 5,

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

newEntity{ define_as = "ATHAME_WEST",
	quest=true, unique="Blood-Runed Athame West", identified=true, no_unique_lore=true,
	type = "misc", subtype="misc",
	unided_name = "athame",
	name = "Blood-Runed Athame", image = "object/artifact/blood_runed_athame.png",
	level_range = {50, 50},
	display = "|", color=colors.VIOLET,
	encumber = 1,
	desc = [[An athame, covered in blood runes. It radiates power.]],

	on_drop = function(self, who)
		if who == game.player then
			game.logPlayer(who, "You cannot bring yourself to drop the %s", self:getName())
			return true
		end
	end,
}

for i = 1, 4 do
newEntity{ base = "BASE_LORE",
	define_as = "IRON_THRONE_PROFIT"..i,
	name = "Iron Throne Profits History", lore="iron-throne-profits-"..i,
	desc = [[A journal of the profits history of the Iron Throne dwarves.]],
	rarity = false,
	encumberance = 0,
}
end

newEntity{ base = "BASE_LORE",
	define_as = "IRON_THRONE_LEDGER",
	name = "Iron Throne trade ledger", lore="iron-throne-trade-ledger",
	desc = [[A trade ledger of the Iron Throne dwarves.]],
	rarity = false,
	encumberance = 0,
}

newEntity{ base = "BASE_LORE",
	define_as = "IRON_THRONE_LAST_WORDS",
	name = "Iron Throne Reknor expedition, last words", lore="iron-throne-last-words",
	desc = [[Last words of a dwarven expedition to secure Reknor.]],
	rarity = false,
	encumberance = 0,
}
