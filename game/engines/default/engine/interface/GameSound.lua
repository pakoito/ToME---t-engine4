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

--- Handles sounds in the game
module(..., package.seeall, class.make)

--- Initializes
function _M:init()
	self.loaded_sounds = {}
--	setmetatable(self.loaded_sounds, {__mode="v"})
end

function _M:loaded()
	self.loaded_sounds = self.loaded_sounds or {}
--	setmetatable(self.loaded_sounds, {__mode="v"})
end

function _M:playSound(name)
	local s = self.loaded_sounds[name]
	if not s then
		local def, ok
		if fs.exists("/data/sound/"..name..".lua") then
			local f = loadfile("/data/sound/"..name..".lua")
			setfenv(f, setmetatable({}, {__index=_G}))
			def = f()
			print("[SOUND] loading from", "/data/sound/"..name..".lua", ":=:", "/data/sound/"..def.file, ":>")
			ok, def.sample = pcall(core.sound.load, "/data/sound/"..def.file)
			if not ok then return end
			print("[SOUND] :=>", def.sample)
			if def.volume and def.sample then def.sample:volume(def.volume / 100) end
		elseif fs.exists("/data/sound/"..name..".ogg") then
			def = {}
			ok, def.sample = pcall(core.sound.load, "/data/sound/"..name..".ogg")
			if not ok then return end
			print("[SOUND] loading from", "/data/sound/"..name..".ogg", ":=:", def.sample)
		else
			def = {}
		end

		self.loaded_sounds[name] = def
		s = self.loaded_sounds[name]
	end
	if not s or not s.sample then return end
	s.sample:play(s.loop)
	return s
end
