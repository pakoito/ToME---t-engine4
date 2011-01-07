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

--- Handles tiles
-- Used by engine.Map to reduce processing needed. Module authors wont use it directly mostly.
module(..., package.seeall, class.make)

prefix = "/data/gfx/"
base_prefix = "/data/gfx/"
use_images = true
force_back_color = nil

function _M:init(w, h, fontname, fontsize, texture, allow_backcolor)
	self.allow_backcolor = allow_backcolor
	self.texture = texture
	self.w, self.h = w, h
	self.font = core.display.newFont(fontname or "/data/font/VeraMoBd.ttf", fontsize or 14)
	self.repo = {}
	self.texture_store = {}
end

function _M:loadImage(image)
	local s = core.display.loadImage(self.prefix..image)
	if not s then s = core.display.loadImage(self.base_prefix..image) end
	return s
end

function _M:get(char, fr, fg, fb, br, bg, bb, image, alpha, do_outline)
	if self.force_back_color then br, bg, bb, alpha = self.force_back_color.r, self.force_back_color.g, self.force_back_color.b, self.force_back_color.a end

	alpha = alpha or 0
	local dochar = char
	local fgidx = 65536 * fr + 256 * fg + fb
	local bgidx
	if br >= 0 and bg >= 0 and bb >= 0 then
		bgidx = 65536 * br + 256 * bg + bb
	else
		bgidx = "none"
	end

	if (self.use_images or not dochar) and image then char = image end

	if self.repo[char] and self.repo[char][fgidx] and self.repo[char][fgidx][bgidx] then
		return self.repo[char][fgidx][bgidx]
	else
		local s
		local is_image = false
		if (self.use_images or not dochar) and image then
			print("Loading tile", image)
			s = core.display.loadImage(self.prefix..image)
			if not s then s = core.display.loadImage(self.base_prefix..image) end
			if s then is_image = true end
		end
		if not s then
			local w, h = self.font:size(dochar)
--[[
			s = core.display.newSurface(self.w, self.h)
			if br >= 0 then
				s:erase(br, bg, bb, alpha)
			else
				s:erase(0, 0, 0, alpha)
			end

			s:drawString(self.font, char, (self.w - w) / 2, (self.h - h) / 2, fr, fg, fb)
]]
			if not self.allow_backcolor or br < 0 then br = nil end
			if not self.allow_backcolor or bg < 0 then bg = nil end
			if not self.allow_backcolor or bb < 0 then bb = nil end
			if not self.allow_backcolor then alpha = 0 end
			s = core.display.newTile(self.w, self.h, self.font, dochar, (self.w - w) / 2, (self.h - h) / 2, fr, fg, fb, br or 0, bg or 0, bb or 0, alpha, self.use_images)
--			s = core.display.drawStringNewSurface(self.font, char, fr, fg, fb)
		end

		if self.texture then
			s = s:glTexture()
			if not is_image and do_outline then
				if type(do_outline) == "boolean" then
					s = s:makeOutline(2, 2, self.w, self.h, 0, 0, 0, 1) or s
				else
					s = s:makeOutline(do_outline.x, do_outline.y, self.w, self.h, do_outline.r, do_outline.g, do_outline.b, do_outline.a) or s
				end
			end
		end

		self.repo[char] = self.repo[char] or {}
		self.repo[char][fgidx] = self.repo[char][fgidx] or {}
		self.repo[char][fgidx][bgidx] = s
		return s
	end
end

function _M:clean()
	self.repo = {}
	self.texture_store = {}
	collectgarbage("collect")
end
