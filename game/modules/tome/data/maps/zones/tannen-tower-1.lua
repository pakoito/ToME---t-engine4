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

-- defineTile section
defineTile("g", "FLOOR", nil, "DROLEM")
defineTile("X", "HARDWALL")
quickEntity('=', {name='open sky', display=' ', does_block_move=true})
defineTile("p", "FLOOR", nil, "TANNEN")
defineTile(".", "FLOOR")

-- addSpot section
startx = 12
starty = 12

-- ASCII map section
return [[
=========================
==========XXXXX==========
=======...........=======
=====X.............X=====
====XX.............XX====
===XX...............XX===
===...................===
==.....................==
==...p.................==
==.....................==
=X.....................X=
=X.....................X=
=X.........g...........X=
=X.....................X=
=X.....................X=
==.....................==
==.....................==
==.....................==
===...................===
===XX...............XX===
====XX.............XX====
=====X.............X=====
=======...........=======
==========XXXXX==========
=========================]]
