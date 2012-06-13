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
local Base = require "engine.ui.Base"
local Focusable = require "engine.ui.Focusable"
local Slider = require "engine.ui.Slider"

--- A talent trees display
module(..., package.seeall, class.inherit(Base, Focusable))

function _M:init(t)
	self.tiles = assert(t.tiles, "no Tiles class")
	self.tree = assert(t.tree, "no talent tree")
	self.w = assert(t.width, "no width")
	self.h = assert(t.height, "no height")
	self.tooltip = assert(t.tooltip, "no tooltip")
	self.on_use = assert(t.on_use, "no on_use")

	self.icon_size = 48
	self.frame_size = 50
	self.icon_offset = 1
	self.frame_offset = 5

	self.shadow = 0.7

	self.talent_frame = self:makeFrame("ui/icon-frame/frame", self.frame_size, self.frame_size)
	self.plus = _M:getUITexture("ui/plus.png")
	self.minus = _M:getUITexture("ui/minus.png")

	Base.init(self, t)
end

function _M:onUse(item, inc)
	self.on_use(item, inc)
end

function _M:updateTooltip()
	if not self.last_mz then
		game.tooltip_x = nil
		return 
	end
	local mz = self.last_mz
	local str = self.tooltip(mz.item)
	game:tooltipDisplayAtMap(self.last_display_x + mz.x2, self.last_display_y + mz.y1, str)
end

function _M:doScroll(v)
	self.scroll = util.bound(self.scroll + v, 1, self.max_display)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self.scroll = 1

	-- Draw the scrollbar
	if self.scrollbar then
		self.scrollbar = Slider.new{size=self.h - fh, max=1}
	end

	self.mousezones = {}

	for i = 1, #self.tree do
		local tree = self.tree[i]
		self:drawItem(tree)
		for j = 1, #tree.nodes do
			local tal = tree.nodes[j]
			self:drawItem(tal)
		end
	end

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if event == "button" and button == "wheelup" then self:doScroll(-1)
		elseif event == "button" and button == "wheeldown" then self:doScroll(1)
		end

		local done = false
		for i = 1, #self.mousezones do
			local mz = self.mousezones[i]
			if x >= mz.x1 and x <= mz.x2 and y >= mz.y1 and y <= mz.y2 then
				if not self.last_mz or mz.item ~= self.last_mz.item then
					local str = self.tooltip(mz.item)
					game:tooltipDisplayAtMap(self.last_display_x + mz.x2, self.last_display_y + mz.y1, str)
				end

				if event == "button" and (button == "left" or button == "right") then self:onUse(mz.item, button == "left") end
				
				self.last_mz = mz
				done = true
				break
			end
		end
		if not done then game.tooltip_x = nil self.last_mz = nil end
	end)
	self.key:addBinds{
		ACCEPT = function() self:onUse("left", "key") end,
		MOVE_UP = function()
		end,
		MOVE_DOWN = function()
		end,
	}
	self.key:addCommands{
		[{"_UP","ctrl"}] = function() self.key:triggerVirtual("MOVE_UP") end,
		[{"_DOWN","ctrl"}] = function() self.key:triggerVirtual("MOVE_DOWN") end,
		_HOME = function()
		end,
		_END = function()
		end,
		_PAGEUP = function()
		end,
		_PAGEDOWN = function()
		end,
	}
end

function _M:drawItem(item)
	if item.talent then
		local str = item:status():toString()
		local d = self.font:draw(str, self.font:size(str), 255, 255, 255, true)[1]
		item.text_status = d
	elseif item.type then
		local str = item:rawname():toString()
		local d = self.font:draw(str, self.font:size(str), 255, 255, 255, true)[1]
		item.text_status = d
	end
end

function _M:display(x, y, nb_keyframes, screen_x, screen_y)
	self.last_display_x = screen_x
	self.last_display_y = screen_y

	local mz = {}
	self.mousezones = mz

	local dx, dy = 0, 0

	self.max_display = 1
	for i = self.scroll, #self.tree do
		local tree = self.tree[i]

		if tree.text_status then
			local key = tree.text_status
			if self.shadow then key._tex:toScreenFull(dx+x + 2, dy+y + 2, key.w, key.h, key._tex_w, key._tex_h, 0, 0, 0, self.shadow) end
			key._tex:toScreenFull(dx+x, dy+y, key.w, key.h, key._tex_w, key._tex_h)
			dy = dy + key.h + 4
		end

		local addh = 0
		for j = 1, #tree.nodes do
			local tal = tree.nodes[j]

			tal.entity:toScreen(self.tiles, dx+x + self.icon_offset, dy+y + self.icon_offset, self.icon_size, self.icon_size)

			local rgb = tal:color()
			self:drawFrame(self.talent_frame, dx+x, dy+y, rgb[1]/255, rgb[2]/255, rgb[3]/255, 1)

			mz[#mz+1] = {item=tal, x1=dx, y1=dy, x2=dx+self.frame_size, y2=dy+self.frame_size}

			if tal.text_status then
				local key = tal.text_status
				if self.shadow then key._tex:toScreenFull(dx+x + (self.frame_size - key.w)/2 + 2, dy+y + self.frame_size + 4, key.w, key.h, key._tex_w, key._tex_h, 0, 0, 0, self.shadow) end
				key._tex:toScreenFull(dx+x + (self.frame_size - key.w)/2, dy+y + self.frame_size + 2, key.w, key.h, key._tex_w, key._tex_h)
				addh = key.h
			end

			dx = dx + self.frame_size + self.frame_offset
		end
		self.max_display = i
		dx = 0
		dy = dy + self.frame_size + addh + 12
		if dy + self.frame_size >= self.h then break end
	end

	if self.focused and self.scrollbar then
		self.scrollbar.pos = self.sel
		self.scrollbar:display(bx + self.w - self.scrollbar.w, by + self.fh)
	end
end
