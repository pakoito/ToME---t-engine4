-- ToME - Tales of Maj'Eyal
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
local Map = require "engine.Map"

module(..., package.seeall, class.make)

function _M:init(font, size)
	self.font = core.display.newFont(font, size, true)
	self.font:setStyle("bold")
	self.text_shadow = 0.8
end

function _M:say(time, txt, ...)
	txt = txt:format(...)
	self.time = time or 60
	self.max_time = self.time
	self.list, self.max_lines, self.max_w = self.font:draw(txt:toString(), math.floor(game.w * 0.8), 255, 255, 255)

	self.list_x = (- self.max_w) / 2
	self.list_y = (- self.list[1].h * #self.list) / 2

	self.center_x = (game.w) / 2
	self.center_y = (game.h) / 2
end

function _M:display(nb_keyframes)
	if not self.list then return end

	core.display.glTranslate(self.center_x, self.center_y, 0)
	local scale = util.bound(1-math.log10(self.time / self.max_time)^2, 0, 1)
	core.display.glScale(scale, scale, scale)

	local x = self.list_x
	local y = self.list_y

	for i = 1, #self.list do
		local item = self.list[i]
		if not item then break end

		if self.text_shadow then item._tex:toScreenFull(x+4, y+4, item.w, item.h, item._tex_w, item._tex_h, 0, 0, 0, self.text_shadow) end
		item._tex:toScreenFull(x, y, item.w, item.h, item._tex_w, item._tex_h)
		y = y + item.h
	end

	self.time = self.time - nb_keyframes
	if self.time < 0 then
		self.time = nil
		self.list = nil
	end

	core.display.glScale()
	core.display.glTranslate(-self.center_x, -self.center_y, 0)
end
