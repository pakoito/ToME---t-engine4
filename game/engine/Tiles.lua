require "engine.class"

--- Handles tiles
-- Used by engine.Map to reduce processing needed. Module authors wont use it directly mostly.
module(..., package.seeall, class.make)

prefix = "/data/gfx/"
use_images = true

function _M:init(w, h, fontname, fontsize, texture)
	self.texture = texture
	self.w, self.h = w, h
	self.font = core.display.newFont(fontname or "/data/font/VeraMoBd.ttf", fontsize or 14)
	self.repo = {}
end

function _M:get(char, fr, fg, fb, br, bg, bb, image, alpha)
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
		if (self.use_images or not dochar) and image then
			print("Loading tile", image)
			s = core.display.loadImage(self.prefix..image)
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
			if br < 0 then br = nil end
			if bg < 0 then bg = nil end
			if bb < 0 then bb = nil end
			s = core.display.newTile(self.w, self.h, self.font, dochar, (self.w - w) / 2, (self.h - h) / 2, fr, fg, fb, br or 0, bg or 0, bb or 0, alpha, self.use_images)
--			s = core.display.drawStringNewSurface(self.font, char, fr, fg, fb)
		end

		if self.texture then s = s:glTexture() end

		self.repo[char] = self.repo[char] or {}
		self.repo[char][fgidx] = self.repo[char][fgidx] or {}
		self.repo[char][fgidx][bgidx] = s
		return s
	end
end

function _M:clean()
	self.repo = {}
end
