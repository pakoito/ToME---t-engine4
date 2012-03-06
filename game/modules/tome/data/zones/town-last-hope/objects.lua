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

for i = 1, 6 do
newEntity{ base = "BASE_LORE",
	define_as = "FOUNDATION_NOTE"..i,
	subtype = "last hope foundation", unique=true, no_unique_lore=true, not_in_stores=false,
	name = "The Diaries of King Toknor the Brave ("..i..")", lore="last-hope-foundation-note-"..i,
	desc = [[A part of the history of Last Hope, and king Toknor the Brave.]],
	rarity = false,
	encumberance = 0,
	cost = 2,
}
end

for i = 0, 2 do
local l = mod.class.interface.PlayerLore.lore_defs["races-"..i]
newEntity{ base = "BASE_LORE",
	define_as = "RACES_NOTE"..i,
	subtype = "analysis", unique=true, no_unique_lore=true, not_in_stores=false,
	name = l.name, lore="races-"..i,
	rarity = false,
	encumberance = 0,
	cost = 2,
}
end

for i = 1, 2 do
newEntity{ base = "BASE_LORE",
	define_as = "SOUTHSPAR_NOTE"..i,
	subtype = "southspar", unique=true, no_unique_lore=true, not_in_stores=false,
	name = "the Pale King part "..(i==1 and "one" or "two"), lore="southspar-note-"..i,
	desc = [[A study into Southspar's most unusual ruler.]],
	rarity = false,
	encumberance = 0,
	cost = 2,
}
end
