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

load("/data/general/npcs/bear.lua", rarity(0))
load("/data/general/npcs/vermin.lua", rarity(3))
load("/data/general/npcs/canine.lua", rarity(1))
load("/data/general/npcs/snake.lua", rarity(0))
load("/data/general/npcs/plant.lua", rarity(0))
load("/data/general/npcs/faeros.lua", rarity(0))

load("/data/general/npcs/all.lua", rarity(4, 35))

-- Everything is poison immune in the caldera, they couldnt live there otherwise
for i, e in ipairs(loading_list) do
	if e.name then e.poison_immune = 1 end
end
