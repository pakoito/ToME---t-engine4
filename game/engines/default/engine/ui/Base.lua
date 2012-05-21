-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
_M.font = core.display.newFont("/data/font/DroidSans.ttf", 12)
_M.font_h = _M.font:lineSkip()
_M.font_mono = core.display.newFont("/data/font/DroidSansMono.ttf", 12)
_M.font_mono_w = _M.font_mono:size(" ")
_M.font_mono_h = _M.font_mono:lineSkip()
_M.font_bold = core.display.newFont("/data/font/DroidSans-Bold.ttf", 12)
_M.font_bold_h = _M.font_bold:lineSkip()

-- Default UI
_M.ui = "metal"
_M.defaultui = "metal"

sounds = {
	button = "ui/subtle_button_sound",
}

_M.ui_conf = {
	metal = {
		frame_shadow = {x=15, y=15, a=0.5},
		frame_alpha = 1,
		frame_ox1 = -42,
		frame_ox2 =  42,
		frame_oy1 = -42,
		frame_oy2 =  42,
		title_bar = {x=0, y=-21, w=4, h=25},
	},
	stone = {
		frame_shadow = {x=15, y=15, a=0.5},
		frame_alpha = 1,
		frame_ox1 = -42,
		frame_ox2 =  42,
		frame_oy1 = -42,
		frame_oy2 =  42,
	},
	simple = {
		frame_shadow = nil,
		frame_alpha = 0.9,
		frame_ox1 = -2,
		frame_ox2 =  2,
		frame_oy1 = -2,
		frame_oy2 =  2,
	},
	parchment = {
		frame_shadow = {x = 10, y = 10, a = 0.5},
		frame_ox1 = -16,
		frame_ox2 = 16,
		frame_oy1 = -16,
		frame_oy2 = 16,
	},
	tombstone = {
		frame_shadow = {x = 10, y = 10, a = 0.5},
		frame_ox1 = -16,
		frame_ox2 = 16,
		frame_oy1 = -16,
		frame_oy2 = 16,
	},
}

function _M:inherited(base)
	if base._NAME == "engine.ui.Base" then
		self.font = base.font
		self.font_h = base.font_h
		self.font_mono = base.font_mono
		self.font_mono_w = base.font_mono_w
		self.font_mono_h = base.font_mono_h
		self.font_bold = base.font_bold
		self.font_bold_h = base.font_bold_h
	end
end

function _M:init(t, no_gen)
	self.mouse = Mouse.new()
	self.key = KeyBind.new()

	if not rawget(self, "ui") then self.ui = self.ui end

	if t.font then
		if type(t.font) == "table" then
			self.font = core.display.newFont(t.font[1], t.font[2])
			self.font_h = self.font:lineSkip()
		else
			self.font = t.font
			self.font_h = self.font:lineSkip()
		end
	end

	if t.ui then self.ui = t.ui end

	if not no_gen then self:generate() end
end

function _M:getImage(file, noerror)
	if cache[file] then return unpack(cache[file]) end
	local s = core.display.loadImage(gfx_prefix..file)
	if noerror and not s then return end
	assert(s, "bad UI image: "..file)
	s:alpha(true)
	cache[file] = {s, s:getSize()}
	return unpack(cache[file])
end

function _M:getUITexture(file)
	local uifile = (self.ui ~= "" and self.ui.."-" or "")..file
	if tcache[uifile] then return tcache[uifile] end
	local i, w, h = self:getImage(uifile, true)
	if not i then i, w, h = self:getImage(self.defaultui.."-"..file) end
	if not i then error("bad UI texture: "..uifile) return end
	local t, tw, th = i:glTexture()
	local r = {t=t, w=w, h=h, tw=tw, th=th}
	tcache[uifile] = r
	return r
end

function _M:makeFrame(base, w, h)
	local f = {}
	if base then
		f.b7 = self:getUITexture(base.."7.png")
		f.b9 = self:getUITexture(base.."9.png")
		f.b1 = self:getUITexture(base.."1.png")
		f.b3 = self:getUITexture(base.."3.png")
		f.b8 = self:getUITexture(base.."8.png")
		f.b4 = self:getUITexture(base.."4.png")
		f.b2 = self:getUITexture(base.."2.png")
		f.b6 = self:getUITexture(base.."6.png")
		f.b5 = self:getUITexture(base.."5.png")
	end
	f.w = math.floor(w)
	f.h = math.floor(h)
	return f
end

function _M:drawFrame(f, x, y, r, g, b, a)
	if not f.b7 then return end

	x = math.floor(x)
	y = math.floor(y)

	-- Sides
	f.b8.t:toScreenFull(x + f.b7.w, y, f.w - f.b7.w - f.b9.w + 1, f.b8.h, f.b8.tw, f.b8.th, r, g, b, a)
	f.b2.t:toScreenFull(x + f.b7.w, y + f.h - f.b3.h + 1, f.w - f.b7.w - f.b9.w + 1, f.b2.h, f.b2.tw, f.b2.th, r, g, b, a)
	f.b4.t:toScreenFull(x, y + f.b7.h, f.b4.w, f.h - f.b7.h - f.b1.h + 1, f.b4.tw, f.b4.th, r, g, b, a)
	f.b6.t:toScreenFull(x + f.w - f.b9.w + 1, y + f.b7.h, f.b6.w, f.h - f.b7.h - f.b1.h + 1, f.b6.tw, f.b6.th, r, g, b, a)

	-- Body
	f.b5.t:toScreenFull(x + f.b7.w, y + f.b7.h, f.w - f.b7.w - f.b3.w + 1, f.h - f.b7.h - f.b3.h + 1, f.b6.tw, f.b6.th, r, g, b, a)

	-- Corners
	f.b7.t:toScreenFull(x, y, f.b7.w, f.b7.h, f.b7.tw, f.b7.th, r, g, b, a)
	f.b1.t:toScreenFull(x, y + f.h - f.b1.h + 1, f.b1.w, f.b1.h, f.b1.tw, f.b1.th, r, g, b, a)
	f.b9.t:toScreenFull(x + f.w - f.b9.w + 1, y, f.b9.w, f.b9.h, f.b9.tw, f.b9.th, r, g, b, a)
	f.b3.t:toScreenFull(x + f.w - f.b3.w + 1, y + f.h - f.b3.h + 1, f.b3.w, f.b3.h, f.b3.tw, f.b3.th, r, g, b, a)
end

function _M:setTextShadow(v)
	self.text_shadow = v
end

function _M:positioned(x, y)
end

function _M:sound(name)
	if game.playSound and sounds[name] then
		game:playSound(sounds[name])
	end
end

function _M:makeKeyChar(i)
	i = i - 1
	if i < 26 then
		return string.char(string.byte('a') + i)
	elseif i < 52 then
		return string.char(string.byte('A') + i - 26)
	elseif i < 62 then
		return string.char(string.byte('0') + i - 52)
	else
		-- Invalid
		return "  "
	end
end
