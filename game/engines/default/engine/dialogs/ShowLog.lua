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
local Dialog = require "engine.ui.Dialog"
local Slider = require "engine.ui.Slider"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, shadow, log)
	local w = math.floor(game.w * 0.9)
	local h = math.floor(game.h * 0.9)
	Dialog.init(self, title, w, h)
	if shadow then self.shadow = shadow end

	self:loadUI{}
	self:setupUI()

	self.lines = {}
	for i = #log.log, 1, -1 do
		self.lines[#self.lines+1] = log.log[i]
	end

	self.max_h = self.ih - self.iy
	self.max = #log.log
	self.max_display = math.floor(self.max_h / self.font_h)

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if button == "wheelup" and event == "button" then self.key:triggerVirtual("MOVE_UP")
		elseif button == "wheeldown" and event == "button" then self.key:triggerVirtual("MOVE_DOWN")
		end
	end)
	self.key:addBinds{
		MOVE_UP = function() self:setScroll(self.scroll - 1) end,
		MOVE_DOWN = function() self:setScroll(self.scroll + 1) end,
		ACCEPT = "EXIT",
		EXIT = function() game:unregisterDialog(self) end,
	}
	self.key:addCommands{
		_HOME = function() self:setScroll(1) end,
		_END = function() self:setScroll(self.max) end,
		_PAGEUP = function() self:setScroll(self.scroll - self.max_display) end,
		_PAGEDOWN = function() self:setScroll(self.scroll + self.max_display) end,
	}

	self.scrollbar = Slider.new{size=self.h - 20, max=1, inverse=true}
	self.scrollbar.max = self.max - self.max_display + 1

	self:setScroll(self.max - self.max_display + 1)
end

function _M:setScroll(i)
	local old = self.scroll
	self.scroll = util.bound(i, 1, math.max(1, self.max - self.max_display + 1))
	if self.scroll == old then return end

	self.dlist = {}
	local nb = 0
	local old_style = self.font:getStyle()
	for z = 1 + self.scroll, #self.lines do
		local stop = false
		local tstr = self.lines[z]
		if not tstr then break end
		local gen = self.font:draw(tstr, self.iw - 10, 255, 255, 255)
		for i = 1, #gen do
			self.dlist[#self.dlist+1] = gen[i]
			nb = nb + 1
			if nb >= self.max_display then stop = true break end
		end
		if stop then break end
	end
	self.font:setStyle(old_style)
end

function _M:innerDisplay(x, y, nb_keyframes)
	local h = y + self.iy
	for i = 1, #self.dlist do
		local item = self.dlist[i]
		if self.shadow then item._tex:toScreenFull(x+2, h+2, item.w, item.h, item._tex_w, item._tex_h, 0,0,0, self.shadow) end
		item._tex:toScreenFull(x, h, item.w, item.h, item._tex_w, item._tex_h)
		h = h + self.font_h
	end

	self.scrollbar.pos = self.scrollbar.max - self.scroll + 1
	self.scrollbar:display(x + self.iw - self.scrollbar.w, y)
end
