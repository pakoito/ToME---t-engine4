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

startx = 0
starty = 10
endx = 18
endy = 18

local list = {}
for i = 1, 44 do list[#list+1] = i end

-- defineTile section
defineTile("*", function() local v = rng.tableRemove(list) if not v then v = "" end return "GRAVE"..v end)
defineTile("<", "GRASS_UP_WILDERNESS")
defineTile("_", "ROAD")
defineTile(">", "MAUSOLEUM")
defineTile(".", "GRASS")
defineTile("t", "SWAMPTREE")

-- addSpot section

-- addZone section

-- ASCII map section
return [[
tttttttttttttttttttt
tttttttttttttttttttt
._..._..._..._..._.t
___________________t
._.*._.*._.*._.*._.t
._..._..._..._..._.t
._*t*_*t*_*t*_*t*_*t
._.t._.t._.t._.t._.t
._*.*_*.*_*.*_*.*_*t
._..._..._..._..._.t
<__________________t
._..._..._..._..._.t
._*.*_*.*_*.*_*.*_*t
._.t._.t._.t._.t._.t
._*t*_*t*_*t*_*t*_*t
._..._..._..._..._.t
._.*._.*._.*._.*._.t
___________________t
._..._..__..._..._>t
tttttttttttttttttttt]]
