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

for i = 1, 8 do
local l = mod.class.interface.PartyLore.lore_defs["spellblaze-chronicles-"..i]
newEntity{ base = "BASE_LORE",
	define_as = "SPELLBLAZE_NOTE"..i,
	subtype = "spellblaze", unique=true, no_unique_lore=true, not_in_stores=false,
	name = l.name, lore="spellblaze-chronicles-"..i,
	rarity = false,
	encumberance = 0,
	cost = 70,
}
end
