-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

local def = {lite=true}
defineTile('<', "GRASS_UP_WILDERNESS", nil, nil, nil, def)
defineTile('.', "FLOOR", nil, nil, nil, def)
defineTile(';', "GRASS", nil, nil, nil, def)
defineTile('+', "DOOR", nil, nil, nil, def)
defineTile('T', "TREE", nil, nil, nil, def)
defineTile('#', "WALL", nil, nil, nil, def)
defineTile('C', "GRASS", nil, "BEN_CRUTHDAR", nil, def)

startx = 24
starty = 24

return [[
TTTTTTTTTTTTTTTTTTTTTTTTT
TTTTTTTTTTTTTTTTTTTTTTTTT
TTTT;;;;;;;;;;;TTTTTTTTTT
TT;;;#####;;;;;;;;;TTTTTT
TT;;;#...#;;;;;;;;;;;;TTT
TT;;;###+#;;;##+##;;;;;TT
TTT;;;;;;;;;;#...##;;;TTT
TTTTT;;;;C;;;#...##;;;TTT
TTTTTT#;;;;;;#####;;TTTTT
TTT...+;;;;;;;;;;;;;TTTTT
TTT...#;;;;;;;;;;;;;;TTTT
TTTT..#;;;;;;;;;;;#+#TTTT
TTTTT.#;;;;;;;;;###..TTTT
TTTTTTT;;;;;;;;TT.....TTT
TTTT;;;;;;;;;;;TTT...TTTT
TTTT;;##+##;;;;;;TTTTTTTT
TTTT;;#..##;;;;;;;TTTTTTT
TTTT;;#..#;;;;;;;;TTTTTTT
TTTT;;####;;;;;;;;TTTTTTT
TTTTT;;;;;;;;;;;;;TTTTTTT
TTTTT;;;;;;;;;;;;;;TTTTTT
TTTTTT;;;;##TTTTTT;TTTTTT
TTTTTTT;;##....TTT;;;;TTT
TTTTTTTT;+.....TTTTTT;;TT
TTTTTTTTTTTTTTTTTTTTTT;;<]]
