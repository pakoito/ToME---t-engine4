-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
	self.next_music = nil
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
	print("[MUSIC] playing", name, m, " :: current ? ", self.playing_music)
	if self.current_music == name and self.playing_music then return end
	if self.current_music then
		core.sound.musicStop()
	end
	m:play(loop or -1)
	self.current_music = name
	self.playing_music = true
end

function _M:stopMusic(fadeout)
	if not self.loaded_musics[self.current_music] then return end
	core.sound.musicStop(fadeout)
	self.current_music = nil
	self.playing_music = false
end

function _M:volumeMusic(vol)
	if vol then
		self:saveSettings("music", ("music.volume = %q\n"):format(vol))
	end
	return core.sound.musicVolume(vol) or 0
end

--- Called by the C core when the current music stops
function _M:onMusicStop()
end

function _M:soundSystemStatus(act, init_setup)
	if type(act) == "boolean" then
		core.sound.soundSystemStatus(act)
		if not init_setup then
			self:saveSettings("sound", ("sound.enabled = %s\n"):format(act and "true" or "false"))
			if act then
				self:playMusic()
			else
				local o = self.current_music
				self:stopMusic()
				self.current_music = o
			end
		end
	else
		return core.sound.soundSystemStatus()
	end
end
