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

--- Handles music in the game
module(..., package.seeall, class.make)

--- Initializes running
-- We check the direction sides to know if we are in a tunnel, along a wall or in open space.
function _M:init()
	self.current_music = nil
	self.loaded_musics = {}
end

function _M:loaded()
	self.loaded_musics = self.loaded_musics or {}
end

function _M:playMusic(name)
	name = name or self.current_music
	if not name then return end
	local m = self.loaded_musics[name]
	if not m then
		self.loaded_musics[name] = core.sound.newMusic("/data/music/"..name)
		m = self.loaded_musics[name]
	end
	if not m then return end
	if self.current_music then
		self:stopMusic()
	end
	m:play()
	self.current_music = name
end

function _M:stopMusic()
	if not self.loaded_musics[self.current_music] then return end
	self.loaded_musics[self.current_music]:stop()
end
