-- TE4 - T-Engine 4
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
		for name, data in pairs(self.playing_musics) do self:playMusic(name) end
		return
	end
	if self.loaded_musics[name] then return end
	local ok
	ok, self.loaded_musics[name] = pcall(core.sound.load, "/data/music/"..name, false)
	local m = self.loaded_musics[name]
	print("[MUSIC] loading", name, m)
	if not ok or not m then self.loaded_musics[name] = nil return end

	print("[MUSIC] playing", name, m)
	m = m:use() -- Get the source
	m:loop(true)
	m:play()
	m:volume(config.settings.audio.music_volume / 100)
	self.playing_musics[name] = {source=m}
end

function _M:stopMusic(name)
	if not name then
		for name, _ in pairs(self.loaded_musics) do self:stopMusic(name) end
		return
	end

	if not self.loaded_musics[name] then return end
	if self.playing_musics[name].source then self.playing_musics[name].source:stop() end
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
	vol = util.bound(vol, 0, 100)
	if vol then
		config.settings.audio = config.settings.audio or {}
		config.settings.audio.music_volume = vol
		game:audioSaveSettings()
	end
	for name, m in pairs(self.playing_musics) do
		m.source:volume(vol / 100)
	end
end

function _M:audioSaveSettings()
	self:saveSettings("audio", ([[audio.music_volume = %d
audio.effects_volume = %d
audio.enable = %s
]]):
	format(config.settings.audio.music_volume,
		config.settings.audio.effects_volume,
		tostring(config.settings.audio.enable)
	))
end

