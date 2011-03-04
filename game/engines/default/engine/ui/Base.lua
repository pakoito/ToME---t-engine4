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
local tcache = {}

-- Default font
_M.font = core.display.newFont("/data/font/Vera.ttf", 12)
_M.font_h = _M.font:lineSkip()
_M.font_mono = core.display.newFont("/data/font/VeraMono.ttf", 12)
_M.font_mono_w = _M.font_mono:size(" ")
_M.font_mono_h = _M.font_mono:lineSkip()
_M.font_bold = core.display.newFont("/data/font/VeraBd.ttf", 12)
_M.font_bold_h = _M.font_bold:lineSkip()

-- Default UI
_M.ui = "stone"

function _M:init(t, no_gen)
	self.mouse = Mouse.new()
	self.key = KeyBind.new()

	if t.font then
		if type(t.font) == "table" then
			self.font = core.display.newFont(t.font[1], t.font[2])
			self.font_h = self.font:lineSkip()
		else
			self.font = t.font
			self.font_h = self.font:lineSkip()
		end
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

function _M:getTexture(file)
	if tcache[file] then return tcache[file] end
	local i, w, h = self:getImage(file)
	if not i then return end
	local t, tw, th = i:glTexture()
	local r = {t=t, w=w, h=h, tw=tw, th=th}
	tcache[file] = r
	return r
end

function _M:makeFrame(base, w, h)
	local f = {}
	if base then
		f.b7 = self:getTexture(base.."7.png")
		f.b9 = self:getTexture(base.."9.png")
		f.b1 = self:getTexture(base.."1.png")
		f.b3 = self:getTexture(base.."3.png")
		f.b8 = self:getTexture(base.."8.png")
		f.b4 = self:getTexture(base.."4.png")
		f.b2 = self:getTexture(base.."2.png")
		f.b6 = self:getTexture(base.."6.png")
		f.b5 = self:getTexture(base.."5.png")
	end
	f.w = w
	f.h = h
	return f
end

function _M:drawFrame(f, x, y, r, g, b, a)
	if not f.b7 then return end

	-- Sides
	f.b8.t:toScreenFull(x + f.b7.w, y, f.w - f.b7.w - f.b9.w + 1, f.b8.h, f.b8.tw, f.b8.th, r, g, b, a)
	f.b2.t:toScreenFull(x + f.b7.w, y + f.h - f.b3.h, f.w - f.b7.w - f.b9.w + 1, f.b2.h, f.b2.tw, f.b2.th, r, g, b, a)
	f.b4.t:toScreenFull(x, y + f.b7.h, f.b4.w, f.h - f.b7.h - f.b1.h + 1, f.b4.tw, f.b4.th, r, g, b, a)
	f.b6.t:toScreenFull(x + f.w - f.b9.w, y + f.b7.h, f.b6.w, f.h - f.b7.h - f.b1.h + 1, f.b6.tw, f.b6.th, r, g, b, a)

	-- Body
	f.b5.t:toScreenFull(x + f.b7.w, y + f.b7.h, f.w - f.b7.w - f.b3.w + 1, f.h - f.b7.h - f.b3.h + 1, f.b6.tw, f.b6.th, r, g, b, a)

	-- Corners
	f.b7.t:toScreenFull(x, y, f.b7.w, f.b7.h, f.b7.tw, f.b7.th, r, g, b, a)
	f.b1.t:toScreenFull(x, y + f.h - f.b1.h, f.b1.w, f.b1.h, f.b1.tw, f.b1.th, r, g, b, a)
	f.b9.t:toScreenFull(x + f.w - f.b9.w, y, f.b9.w, f.b9.h, f.b9.tw, f.b9.th, r, g, b, a)
	f.b3.t:toScreenFull(x + f.w - f.b3.w, y + f.h - f.b3.h, f.b3.w, f.b3.h, f.b3.tw, f.b3.th, r, g, b, a)
end
