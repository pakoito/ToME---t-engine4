require "engine.class"

module(..., package.seeall, class.make)

function _M:init(w, h, fontname, fontsize)
	self.w, self.h = w, h
	self.font = core.display.newFont(fontname or "/data/font/VeraMono.ttf", fontsize or 14)
	self.repo = {}
end

function _M:get(char, fr, fg, fb, br, bg, bb)
	local fgidx = 65536 * fr + 256 + fg + fb
	local bgidx
	if br >= 0 and bg >= 0 and bb >= 0 then
		bgidx = 65536 * br + 256 + bg + bb
	else
		bgidx = "none"
	end
	if self.repo[char] and self.repo[char][fgidx] and self.repo[char][fgidx][bgidx] then
		return self.repo[char][fgidx][bgidx]
	else
		local s = core.display.newSurface(self.w, self.h)

		if br >= 0 then
			s:erase(br, bg, bb)
		end

		local w, h = self.font:size(char)
		s:drawString(self.font, char, (self.w - w) / 2, (self.h - h) / 2, fr, fg, fb)

		self.repo[char] = self.repo[char] or {}
		self.repo[char][fgidx] = self.repo[char][fgidx] or {}
		self.repo[char][fgidx][bgidx] = s
		return s
	end
end
