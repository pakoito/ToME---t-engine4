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

--- Initializes musics
function _M:init()
	self.current_music = nil
	self.loaded_musics = {}
end

function _M:loaded()
	self.loaded_musics = self.loaded_musics or {}
end

function _M:playMusic(name, loop)
	name = name or self.current_music
	if not name then return end
	local m = self.loaded_musics[name]
	if not m then
		self.loaded_musics[name] = core.sound.newMusic("/data/music/"..name)
		m = self.loaded_musics[name]
	end
	if not m then return end
	if self.current_music == name and self.playing_music then return end
	if self.current_music then
		core.sound.musicStop()
	end
	m:play(loop or -1)
	self.current_music = name
	self.playing_music = true
end

function _M:stopMusic()
	if not self.loaded_musics[self.current_music] then return end
	core.sound.musicStop()
	self.current_music = nil
	self.playing_music = false
end

function _M:volumeMusic(vol)
	core.sound.musicVolume(vol or 100)
end
