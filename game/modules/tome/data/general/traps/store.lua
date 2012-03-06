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

-- We do stores as "traps" to allow them to nicely overlay walls and such
newEntity{ define_as = "BASE_STORE",
	type = "store", subtype="store", identified=true,
	display = '1',
	knownBy = function() return true end,
	triggered = function() end,
	is_store = true,
	z = 18,
	_noalpha = true,
	on_added = function(self, level, x, y)
		-- Change the terrain to be passable since we are not
		game:onTickEnd(function()
			local g = level.map(x, y, engine.Map.TERRAIN)
			g = g:clone()
			g.does_block_move = false
			g.nice_tiler = nil
			level.map(x, y, engine.Map.TERRAIN, g)
		end)
	end,
}
