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
local KeyBind = require "engine.KeyBind"
local Mouse = require "engine.Mouse"

--- A generic UI element
module(..., package.seeall, class.make)

local gfx_prefix = "/data/gfx/"
local cache = {}

-- Default font
_M.font = core.display.newFont("/data/font/Vera.ttf", 12)
_M.font_h = _M.font:lineSkip()
_M.font_mono = core.display.newFont("/data/font/VeraMono.ttf", 12)
_M.font_mono_w = _M.font_mono:size(" ")
_M.font_mono_h = _M.font_mono:lineSkip()

function _M:init(t, no_gen)
	self.mouse = Mouse.new()
	self.key = KeyBind.new()

	if t.font then
		self.font = core.display.newFont(t.font[1], t.font[2])
		self.font_h = self.font:lineSkip()
	end

	if not no_gen then self:generate() end
end

function _M:getImage(file)
	if cache[file] then return unpack(cache[file]) end
	local s = core.display.loadImage(gfx_prefix..file)
	assert(s, "bad UI image: "..file)
	s:alpha(true)
	cache[file] = {s, s:getSize()}
	return unpack(cache[file])
end
