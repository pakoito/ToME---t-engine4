-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local Base = require "engine.ui.Base"

--- A generic waiter bar
module(..., package.seeall, class.inherit(Base))

function _M:init(t)
	self.size = assert(t.size, "no waiter size")
	self.known_max = t.known_max

	Base.init(self, t)
end

function _M:manual()
	core.wait.enableManualTick(true)
	core.display.forceRedraw()
end

function _M:manualStep(nb)
	core.wait.manualTick(nb or 1)
end

function _M:generate()
	local left = core.display.loadImage("/data/gfx/waiter/left_basic.png")
	local right = core.display.loadImage("/data/gfx/waiter/right_basic.png")
	local lw, lh = left:getSize()
	local rw, rh = right:getSize()
	self.w, self.h = self.size + lw + lw, lh
	self.dx = lw
end

function _M:display(x, y)
end

function _M:setTimeout(secs, cb)
	self.timeout_cb = cb
	self.timeout = secs * 1000
	self.timeout_start = core.game.getTime()
end

function _M:getWaitDisplay(d)
	d.__showup = false
	d.unload_wait = rawget(d, "unload")
	d.unload = function(self)
		core.wait.disable()
		if self.unload_wait then self:unload_wait() end
		self.unload = rawget(self, "unload_wait")
	end

	core.display.forceRedraw()

	return function()
		local dx, dy, dw, dh = self.dx + d.ui_by_ui[self].x + d.display_x, d.ui_by_ui[self].y + d.display_y, self.size, self.h
		local has_max = self.known_max
		if has_max then core.wait.addMaxTicks(has_max) end
		local i, max, dir = 0, has_max or 20, 1

		local left = {core.display.loadImage("/data/gfx/waiter/left_basic.png"):glTexture()}
		local right = {core.display.loadImage("/data/gfx/waiter/right_basic.png"):glTexture()}
		local middle = {core.display.loadImage("/data/gfx/waiter/middle.png"):glTexture()}
		local bar = {core.display.loadImage("/data/gfx/waiter/bar.png"):glTexture()}

		return function()
			-- Background
			core.wait.drawLastFrame()

			-- Progressbar
			local x
			if has_max then
				i, max = core.wait.getTicks()
				i = util.bound(i, 0, max)
			else
				i = i + dir
				if dir > 0 and i >= max then dir = -1
				elseif dir < 0 and i <= -max then dir = 1
				end
			end

			local x = dw * (i / max)
			local x2 = x + dw
			x = util.bound(x, 0, dw)
			x2 = util.bound(x2, 0, dw)
			if has_max then x, x2 = 0, x end
			local w, h = x2 - x, dh

			middle[1]:toScreenFull(dx, dy, dw, middle[7], middle[2], middle[3])
			bar[1]:toScreenFull(dx + x, dy, w, bar[7], bar[2], bar[3])
			left[1]:toScreenFull(dx - left[6] + 5, dy + (middle[7] - left[7]) / 2, left[6], left[7], left[2], left[3])
			right[1]:toScreenFull(dx + dw - 5, dy + (middle[7] - right[7]) / 2, right[6], right[7], right[2], right[3])

			if has_max then
				self.font:setStyle("bold")
				local txt = {core.display.drawStringBlendedNewSurface(self.font, math.min(100, math.floor(core.wait.getTicks() * 100 / max)).."%", 255, 255, 255):glTexture()}
				self.font:setStyle("normal")
				txt[1]:toScreenFull(dx + (dw - txt[6]) / 2 + 2, dy + (bar[7] - txt[7]) / 2 + 2, txt[6], txt[7], txt[2], txt[3], 0, 0, 0, 0.6)
				txt[1]:toScreenFull(dx + (dw - txt[6]) / 2, dy + (bar[7] - txt[7]) / 2, txt[6], txt[7], txt[2], txt[3])
			end

			-- Timeout?
			if self.timeout and core.game.getTime() - self.timeout_start >= self.timeout then
				self.timeout_cb()
			end
		end
	end
end
