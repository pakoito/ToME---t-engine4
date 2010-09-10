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

module(..., package.seeall, class.make)

function _M:init(fontname, fontsize)
	self.font = core.display.newFont(fontname or "/data/font/Vera.ttf", fontsize or 12)
	self.bigfont = core.display.newFont(fontname or "/data/font/VeraBd.ttf", fontsize or 18)
	self.font_h = self.font:lineSkip()
	self.flyers = {}
end

function _M:add(x, y, duration, xvel, yvel, str, color, bigfont)
	assert(x, "no x flyer")
	assert(y, "no y flyer")
	assert(str, "no str flyer")
	color = color or {255,255,255}
	local s = core.display.drawStringBlendedNewSurface(bigfont and self.bigfont or self.font, str, color[1], color[2], color[3])
	if not s then return end
	local w, h = s:getSize()
	local t, tw, th = s:glTexture()
	local f = {
		x=x,
		y=y,
		w=w, h=h,
		tw=tw, th=th,
		duration=duration or 10,
		xvel = xvel or 0,
		yvel = yvel or 0,
		t = t,
	}
	self.flyers[f] = true
	return f
end

function _M:empty()
	self.flyers = {}
end

function _M:display()
	if not next(self.flyers) then return end

	local dels = {}

	for fl, _ in pairs(self.flyers) do
		fl.t:toScreenFull(fl.x, fl.y, fl.w, fl.h, fl.tw, fl.th)
		fl.x = fl.x + fl.xvel
		fl.y = fl.y + fl.yvel
		fl.duration = fl.duration - 1

		-- Delete the flyer
		if fl.duration == 0 then
			dels[#dels+1] = fl
		end
	end

	for i, fl in ipairs(dels) do self.flyers[fl] = nil end
end
