-- TE4 - T-Engine 4
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

require "engine.class"

--- Handles sounds in the game
module(..., package.seeall, class.make)

--- Initializes
function _M:init()
	self.playing_sounds = {}
	self.loaded_sounds = {}
--	setmetatable(self.loaded_sounds, {__mode="v"})
end

function _M:loaded()
	self.loaded_sounds = self.loaded_sounds or {}
	self.playing_sounds = {}
--	setmetatable(self.loaded_sounds, {__mode="v"})
end

function _M:playSound(name, position)
	local pitch, vol = nil, 1
	if type(name) == "table" then
		if name[2] and name[3] then name[1] = name[1]:format(rng.range(name[2], name[3])) end
		if name.pitch then pitch = name.pitch end
		if name.vol then vol = name.vol end
		name = name[1]
	end

	local s = self.loaded_sounds[name]
	if not s then
		local def, ok
		if fs.exists("/data/sound/"..name..".lua") then
			local f = loadfile("/data/sound/"..name..".lua")
			setfenv(f, setmetatable({}, {__index=_G}))
			def = f()
			print("[SOUND] loading from", "/data/sound/"..name..".lua", ":=:", "/data/sound/"..def.file, ":>")
			ok, def.sample = pcall(core.sound.load, "/data/sound/"..def.file, false)
			if not ok then print("Failed loading sound", def.file, def.sample) return end
			print("[SOUND] :=>", def.sample)
		elseif fs.exists("/data/sound/"..name..".ogg") then
			def = {}
			ok, def.sample = pcall(core.sound.load, "/data/sound/"..name..".ogg", false)
			if not ok then print("Failed loading sound", name, def.sample) return end
			print("[SOUND] loading from", "/data/sound/"..name..".ogg", ":=:", def.sample)
		else
			def = {}
			print("[SOUND] loading from", "/data/sound/"..name..".ogg", ":=: unknown file")
		end

		self.loaded_sounds[name] = def
		s = self.loaded_sounds[name]
	end
	if not s or not s.sample then return end
	local source = s.sample:use()
	if s.volume then source:volume(vol * (s.volume / 100) * (config.settings.audio.effects_volume / 100))
	else source:volume(vol * config.settings.audio.effects_volume / 100) end
	if position then source:location(position.x, position.y, position.z) end
	if pitch then source:pitch(pitch) end
	source:play()
	self.playing_sounds[source] = true
	return source
end

--- Called on ticks to free up non playing sources
function _M:cleanSounds()
	if not self.playing_sounds then return end
	local todel = {}
	for s, _ in pairs(self.playing_sounds) do
		if not s:playing() then todel[#todel+1] = s end
	end
	for i = 1, #todel do self.playing_sounds[todel[i]] = nil end
end

function _M:volumeSoundEffects(vol)
	vol = util.bound(vol, 0, 100)
	if vol then
		config.settings.audio = config.settings.audio or {}
		config.settings.audio.effects_volume = vol
		game:audioSaveSettings()
	end
	for source, _ in pairs(self.playing_sounds) do
		source:volume(vol / 100)
	end
end
