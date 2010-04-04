-- TE4 - T-Engine 4
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

require "engine.class"

--- Handles sounds in the game
module(..., package.seeall, class.make)

--- Initializes
function _M:init()
	self.loaded_sounds = {}
end

function _M:loaded()
	self.loaded_sounds = self.loaded_sounds or {}
end

function _M:playSound(name)
	local s = self.loaded_sounds[name]
	if not s then
		self.loaded_sounds[name] = core.sound.newSound("/data/sound/"..name)
		s = self.loaded_sounds[name]
	end
	if not s then return end
	s:play()
end
