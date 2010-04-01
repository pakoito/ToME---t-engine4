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

base = {w=5, h=5}

matcher = function(t1, t2)
	if t1 == t2 then return true end
	if t1 == '.' and t2 == '+' then return true end
	if t1 == '.' and t2 == '+' then return true end
	return false
end

tiles =
{

{type="tunnel",
[[##.##]],
[[##.##]],
[[##.##]],
[[##.##]],
[[##.##]],
},

{type="tunnel",
[[##.##]],
[[##.##]],
[[...##]],
[[##.##]],
[[##.##]],
},

{type="tunnel",
[[#####]],
[[#####]],
[[.....]],
[[#####]],
[[#####]],
},

{type="tunnel",
[[##.##]],
[[##.##]],
[[##...]],
[[##.##]],
[[##.##]],
},

{type="tunnel",
[[#####]],
[[#####]],
[[.....]],
[[##.##]],
[[##.##]],
},

{type="tunnel",
[[##.##]],
[[##.##]],
[[.....]],
[[#####]],
[[#####]],
},

{type="tunnel",
[[##.##]],
[[##.##]],
[[.....]],
[[##.##]],
[[##.##]],
},

{type="tunnel",
[[##.##]],
[[##.##]],
[[##...]],
[[#####]],
[[#####]],
},

{type="tunnel",
[[#####]],
[[#####]],
[[...##]],
[[##.##]],
[[##.##]],
},

{type="tunnel",
[[##.##]],
[[##.##]],
[[...##]],
[[#####]],
[[#####]],
},

{type="tunnel",
[[#####]],
[[#####]],
[[##...]],
[[##.##]],
[[##.##]],
},

{type="room",
[[##.##]],
[[#...#]],
[[##.##]],
[[#...#]],
[[#####]],
},

{type="room",
[[##+##]],
[[#...#]],
[[+...+]],
[[#...#]],
[[##+##]],
},

{type="room",
[[##.##]],
[[#....]],
[[#....]],
[[#....]],
[[#####]],
},
{type="room",
[[#####]],
[[....#]],
[[....#]],
[[....#]],
[[#####]],
},
{type="room",
[[#####]],
[[.....]],
[[.....]],
[[.....]],
[[#####]],
},
{type="room",
[[#....]],
[[#....]],
[[+....]],
[[#....]],
[[#####]],
},

{type="room",
[[#####]],
[[#....]],
[[....#]],
[[#....]],
[[#####]],
},
{type="room",
[[#####]],
[[....#]],
[[#....]],
[[....#]],
[[#####]],
},
{type="room",
[[#####]],
[[.....]],
[[#+++#]],
[[.....]],
[[#####]],
},
{type="room",
[[##+##]],
[[##.##]],
[[#...#]],
[[#...#]],
[[#...#]],
},
{type="room",
[[#...#]],
[[#...#]],
[[#...#]],
[[##.##]],
[[##+##]],
},
}
