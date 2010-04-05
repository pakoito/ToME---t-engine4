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
		local def
		if fs.exists("/data/sound/"..name..".lua") then
			local f = loadfile("/data/sound/"..name..".lua")
			setfenv(f, setmetatable({}, {__index=_G}))
			def = f()
			print("[SOUND] loading from", "/data/sound/"..name..".lua", ":=:", "/data/sound/"..def.file, ":>")
			def.file = core.sound.newSound("/data/sound/"..def.file)
			print("[SOUND] :=>", def.file)
			if def.volume then def.file:setVolume(def.volume) end
		elseif fs.exists("/data/sound/"..name..".wav") then
			def = {file = core.sound.newSound("/data/sound/"..name..".wav")}
			print("[SOUND] loading from", "/data/sound/"..name..".wav", ":=:", def.file)
		else
			def = {}
		end

		self.loaded_sounds[name] = def
		s = self.loaded_sounds[name]
	end
	if not s or not s.file then return end
	local chan = s.file:play(s.loop, s.timed)
	if chan and s.fadeout then core.sound.channelFadeOut(chan, s.fadeout) end
end
