-- ToME - Tales of Middle-Earth
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

local Map = require "engine.Map"

Map.zdepth = 4

-- Setup the map to only display one entity
Map.updateMapDisplay = function(self, x, y, mos)
	local g = self(x, y, Map.TERRAIN)
	local o = self(x, y, Map.OBJECT)
	local a = self(x, y, Map.ACTOR)
	local t = self(x, y, Map.TRAP)

	if g then
		-- Update path caches from path strings
		for i = 1, #self.path_strings do
			local ps = self.path_strings[i]
			self._fovcache.path_caches[ps]:set(x, y, g:check("block_move", x, y, ps, false, true))
		end

		g:getMapObjects(self.tiles, mos, 1)
	end
	if t then
		-- Handles trap being known
		if not self.actor_player or t:knownBy(self.actor_player) then
			t:getMapObjects(self.tiles, mos, 2)
		end
	end
	if o then
		o:getMapObjects(self.tiles, mos, 3)
		if self.object_stack_count then
			local mo = o:getMapStackMO(self, x, y)
			if mo then mos[2] = mo end
		end
	end
	if a then
		-- Handles invisibility and telepathy and other such things
		if not self.actor_player or self.actor_player:canSee(a) then
			local r = self.actor_player:reactionToward(a)
			a:getMapObjects(self.tiles, mos, 4)
		end
	end
end
