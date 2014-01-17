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

--- Handles tiles
-- Used by engine.Map to reduce processing needed. Module authors wont use it directly mostly.
module(..., package.seeall, class.make)

prefix = "/data/gfx/"
base_prefix = "/data/gfx/"
use_images = true
force_back_color = nil

tilesets = {}
tilesets_texs = {}
function _M:loadTileset(file)
	local f, err = loadfile(file)
	if err then error(err) end
	local env = {}
	setfenv(f, setmetatable(self.tilesets, {__index={_G=self.tilesets}}))
	local ok, err = pcall(f)
	if not ok then error(err) end
end

function _M:init(w, h, fontname, fontsize, texture, allow_backcolor)
	self.allow_backcolor = allow_backcolor
	self.texture = texture
	self.w, self.h = w, h
	self.font = core.display.newFont(fontname or "/data/font/DroidSansMono.ttf", fontsize or 14)
	self.repo = {}
	self.texture_store = {}
end

function _M:loadImage(image)
	local s = core.display.loadImage(self.prefix..image)
	if not s then s = core.display.loadImage(self.base_prefix..image) end
	return s
end

function _M:checkTileset(f)
	if not self.tilesets[f] then return end
	local d = self.tilesets[f]
--	print("Loading tile from tileset", f)
	local tex = self.tilesets_texs[d.set]
	if not tex then
		tex = core.display.loadImage(d.set):glTexture()
		self.tilesets_texs[d.set] = tex
		print("Loading tileset", d.set)
	end
	return tex, d.factorx, d.factory, d.x, d.y
end

function _M:get(char, fr, fg, fb, br, bg, bb, image, alpha, do_outline, allow_tileset)
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
		local s = self.repo[char][fgidx][bgidx]
		return s[1], s[2], s[3], s[4], s[5]
	else
		local s, sw, sh
		local is_image = false
		if (self.use_images or not dochar) and image and #image > 4 then
			if allow_tileset and self.texture then
				local ts, fx, fy, tsx, tsy = self:checkTileset(self.prefix..image)
				if ts then
					self.repo[char] = self.repo[char] or {}
					self.repo[char][fgidx] = self.repo[char][fgidx] or {}
					self.repo[char][fgidx][bgidx] = {ts, fx, fy, tsx, tsy}
					return ts, fx, fy, tsx, tsy
				end
			end
			print("Loading tile", image)
			s = core.display.loadImage(self.prefix..image)
			if not s then s = core.display.loadImage(self.base_prefix..image) end
			if s then is_image = true end
		end

		local pot_width = math.pow(2, math.ceil(math.log(self.w-0.1) / math.log(2.0)))
		local pot_height = math.pow(2, math.ceil(math.log(self.h-0.1) / math.log(2.0)))

		if not s then
			local w, h = self.font:size(dochar)
			if not self.allow_backcolor or br < 0 then br = nil end
			if not self.allow_backcolor or bg < 0 then bg = nil end
			if not self.allow_backcolor or bb < 0 then bb = nil end
			if not self.allow_backcolor then alpha = 0 end

			s = core.display.newTile(pot_width, pot_height, self.font, dochar, (pot_width - w) / 2, (pot_height - h) / 2, fr, fg, fb, br or 0, bg or 0, bb or 0, alpha, self.use_images)
		end

		if self.texture then
			local w, h = s:getSize()
			s, sw, sh = s:glTexture()
			sw, sh = w / sw, h / sh
			if not is_image and do_outline then
				if type(do_outline) == "boolean" then
					s = s:makeOutline(2*pot_width/self.w, 2*pot_height/self.h, pot_width, pot_height, 0, 0, 0, 1) or s
				else
					s = s:makeOutline(do_outline.x*pot_width/self.w, do_outline.y*pot_height/self.h, pot_width, pot_height, do_outline.r, do_outline.g, do_outline.b, do_outline.a) or s
				end
			end
		else
			sw, sh = s:getSize()
		end

		self.repo[char] = self.repo[char] or {}
		self.repo[char][fgidx] = self.repo[char][fgidx] or {}
		self.repo[char][fgidx][bgidx] = {s, sw, sh}
		return s, sw, sh
	end
end

function _M:clean()
	self.repo = {}
	self.texture_store = {}
	collectgarbage("collect")
end
