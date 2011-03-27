-- ToME - Tales of Maj'Eyal
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

startx = 5
starty = 14
endx = 12
endy = 12

-- defineTile section
defineTile("U", "FLOOR", nil, {random_filter={type="demon"}})
defineTile('"', "OLD_FLOOR", nil, {random_filter={name="greater multi-hued wyrm",add_levels=12}})
defineTile("#", "OLD_WALL")
defineTile("E", "GRASS", nil, {random_filter={type="elemental"}})
defineTile("$", "FLOOR", nil, {random_filter={type="undead", subtype="giant"}})
defineTile("X", "HARDWALL")
defineTile("~", "FLOOR")
defineTile("*", "SEALED_DOOR")
defineTile("+", "DOOR")
defineTile("<", "UP")
defineTile(",", "GRASS")
defineTile(".", "FLOOR")
defineTile(" ", "OLD_FLOOR")
defineTile("!", "WALL")
defineTile("T", "TREE")

addData{post_process = function(level)
	level.nb_to_open = 0
	level.open_doors = function()
		local doors = {{11,12},{12,11},{13,12},{12,13}}
		local g = game.zone:makeEntityByName(game.level, "terrain", "SEALED_DOOR_CRACKED")
		for i, d in ipairs(doors) do game.zone:addEntity(game.level, g, "terrain", d[1], d[2]) end
		game.logPlayer(game.player, "#VIOLET#There is a loud crack coming from the center of the level.")
	end

	-- Need to kill them all
	for uid, a in pairs(level.entities) do
		if a.faction and game.player:reactionToward(a) < 0 then
			a.old_on_die = a.on_die
			a.on_die = function(self, who)
				local nb = 0
				for uid, a in pairs(game.level.entities) do
					local ga = game.level.map(a.x, a.y, engine.Map.ACTOR)
					if a.faction and game.player:reactionToward(a) < 0 and ga and ga == a and not a.dead then nb = nb + 1 end
				end
				if nb <= 0 then game.level.open_doors() end
				self:check("old_on_die")
			end
		end
	end
end}

-- ASCII map section
return [[
XXXXXXXXXXXXXXXXXXXXXXXXX
XXXXXXXXXX.+.+.XXXXXXXXXX
XXXXXXX....X+X....XXXXXXX
XXXXX...X+XX.XXXX...XXXXX
XXXX..XX# #X.X!~X+X..XXXX
XXX..XXX# #X.XU!~!XX..XXX
XXX.XX### #X.X!~!U!XX.XXX
XX..X##   #X.X~!U!~!X..XX
XX.XX#    #X.X!~!~!UXX.XX
XX.XX#  " #X.XU!~!U!~X.XX
X..XX######X.X!U!~!~!X..X
X+XXXXXXXXXX*XXXXXXXXXX+X
X.+........*<*........+.X
X+XXXXXXXXXX*XXX+XXXXXX+X
X..XX......X.XX,,,XXXX..X
XX.XX......X.XEE,EEXXX.XX
XX.XX......X.XEETEEXXX.XX
XX..X....$$X.XEE,EEXX..XX
XXX.XXXXXX+X.XX,,,XXX.XXX
XXX..XX.$..X.XXXXXXX..XXX
XXXX..X+XXXX.XXXXXX..XXXX
XXXXX...XXXX.XXXX...XXXXX
XXXXXXX....X+X....XXXXXXX
XXXXXXXXXX.+.+.XXXXXXXXXX
XXXXXXXXXXXXXXXXXXXXXXXXX]]
