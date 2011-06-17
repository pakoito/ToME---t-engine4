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
	self.playing_musics = {}
end

function _M:loaded()
	self.playing_musics = self.playing_musics or {}
	self.loaded_musics = self.loaded_musics or {}
end

function _M:playMusic(name)
	if not name then
		for name, data in pairs(self.playing_musics) do self:playMusic(name, data.loop) end
		return
	end
	if self.loaded_musics[name] then return end
	self.loaded_musics[name] = core.sound.load("/data/music/"..name)
	local m = self.loaded_musics[name]
	if not m then return end

	print("[MUSIC] playing", name, m, " :: current ? ", self.playing_music)
	m:loop(true)
	m:play()
	self.playing_musics[name] = {loop=true}
end

function _M:stopMusic(name)
	if not name then
		for name, _ in pairs(self.loaded_musics) do self:stopMusic(name) end
		return
	end

	if not self.loaded_musics[name] then return end
	self.loaded_musics[name]:stop()
	self.loaded_musics[name] = nil
	self.playing_musics[name] = nil
	print("[MUSIC] stoping", name)
end

function _M:playAndStopMusic(...)
	local keep = table.reverse{...}
	for name, _ in pairs(self.loaded_musics) do if not keep[name] then self:stopMusic(name) end end
	for name, _ in pairs(keep) do if not self.loaded_musics[name] then self:playMusic(name) end end
end

function _M:volumeMusic(vol)
do return end
	if vol then
		self:saveSettings("music", ("music.volume = %q\n"):format(vol))
	end
	return core.sound.musicVolume(vol) or 0
end

--- Called by the C core when the current music stops
function _M:onMusicStop()
end
