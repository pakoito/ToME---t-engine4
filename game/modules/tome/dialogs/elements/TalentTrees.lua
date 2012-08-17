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
	self.tree = t.tree or {}
	self.w = assert(t.width, "no width")
	self.h = assert(t.height, "no height")
	self.tooltip = assert(t.tooltip, "no tooltip")
	self.on_use = assert(t.on_use, "no on_use")
	self.on_expand = t.on_expand
	
	self.no_cross = t.no_cross
	self.dont_select_top = t.dont_select_top
	self.no_tooltip = t.no_tooltip
	self.clip_area = t.clip_area or { w = self.w, h = self.h }

	self.icon_size = 48
	self.frame_size = 50
	self.icon_offset = 1
	self.frame_offset = 5
	_, self.fh = self.font:size("")
	self.fh = self.fh - 2
	
	self.scrollbar = t.scrollbar
	self.scroll_inertia = 0
	
	self.shadow = 0.7
	self.last_input_was_keyboard = false

	self.frame_sel = self:makeFrame("ui/selector-sel", self.frame_size, self.frame_size)
	self.frame_usel = self:makeFrame("ui/selector", self.frame_size, self.frame_size)
	self.talent_frame = self:makeFrame("ui/icon-frame/frame", self.frame_size, self.frame_size)
	self.plus = _M:getUITexture("ui/plus.png")
	self.minus = _M:getUITexture("ui/minus.png")

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()
	
	-- generate the scrollbar
	if self.scrollbar then self.scrollbar = Slider.new{size=self.h, max=1} end
	
	self.sel_i = 1
	self.sel_j = 1
	self.max_h = 0
	
	self.mousezones = {}
	self:redrawAllItems()
	
	-- calculate each tree items height
	for i = 1, #self.tree do
		local tree = self.tree[i]
		local key = tree.text_status
		local current_h = key and key.h or 0
		if tree.shown then current_h = current_h + self.frame_size + (key and key.h or 0) + 16 end
		self.max_h = self.max_h + current_h
		tree.h = current_h
	end
	
	-- generate the scrollbar
	if self.scrollbar then self.scrollbar.max = self.max_h - self.h + 2 end

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		self.last_input_was_keyboard = false
		
		if event == "button" and button == "wheelup" then if self.scrollbar then self.scroll_inertia = math.min(self.scroll_inertia, 0) - 5 end
		elseif event == "button" and button == "wheeldown" then if self.scrollbar then self.scroll_inertia = math.max(self.scroll_inertia, 0) + 5 end
		end

		if button == "middle" and self.scrollbar then
			if not self.scroll_drag then
				self.scroll_drag = true
				self.scroll_drag_x_start = x
				self.scroll_drag_y_start = y
			else
				self.scrollbar.pos = util.minBound(self.scrollbar.pos + y - self.scroll_drag_y_start, 0, self.scrollbar.max)
				self.scroll_drag_x_start = x
				self.scroll_drag_y_start = y
			end
		else
			self.scroll_drag = false
		end

		if self.last_mz and event == "button" and (button == "left" or button == "right") then
			if self.last_mz.item.type then
				if x - self.last_mz.x1 >= self.plus.w then self:onUse(self.last_mz.item, button == "left")
				elseif not self.no_cross then self:onExpand(self.last_mz.item, button == "left") end
			else
				self:onUse(self.last_mz.item, button == "left")
			end
		end
	end)
	self.key:addBinds{
		ACCEPT = function() if self.last_mz then self:onUse(self.last_mz.item, true) end end,
		MOVE_UP = function() self.last_input_was_keyboard = true self:moveSel(-1, 0) end,
		MOVE_DOWN = function() self.last_input_was_keyboard = true self:moveSel(1, 0) end,
		MOVE_LEFT = function() self.last_input_was_keyboard = true self:moveSel(0, -1) end,
		MOVE_RIGHT = function() self.last_input_was_keyboard = true self:moveSel(0, 1) end,
	}
	self.key:addCommands{
		[{"_RETURN","ctrl"}] = function() if self.last_mz then self:onUse(self.last_mz.item, false) end end,
		[{"_UP","ctrl"}] = function() self.last_input_was_keyboard = false if self.scrollbar then self.scroll_inertia = math.min(self.scroll_inertia, 0) - 5 end end,
		[{"_DOWN","ctrl"}] = function() self.last_input_was_keyboard = false if self.scrollbar then self.scroll_inertia = math.max(self.scroll_inertia, 0) + 5 end end,
		_HOME = function() if self.scrollbar then self.scrollbar.pos = 0 end end,
		_END = function() if self.scrollbar then self.scrollbar.pos = self.scrollbar.max end end,
		_PAGEUP = function() if self.scrollbar then self.scrollbar.pos = util.minBound(self.scrollbar.pos - self.h, 0, self.scrollbar.max) end end,
		_PAGEDOWN = function() if self.scrollbar then self.scrollbar.pos = util.minBound(self.scrollbar.pos + self.h, 0, self.scrollbar.max) end end,
		_SPACE = function() if self.last_mz and self.last_mz.item.type then self:onExpand(self.last_mz.item) end end
	}
end

function _M:onUse(item, inc)
	self.on_use(item, inc)
end

function _M:onExpand(item, inc)
	item.shown = not item.shown
	local current_h = item.shown and (self.frame_size + 2 * self.fh + 16) or self.fh
	self.max_h = self.max_h + (item.shown and 1 or -1 ) * (self.frame_size + self.fh + 16)
	if self.scrollbar then 
		self.scrollbar.max = self.max_h - self.h 
		self.scrollbar.pos = util.minBound(self.scrollbar.pos, 0, self.scrollbar.max)
	end
	item.h = current_h
	if self.on_expand then self.on_expand(item) end
end

function _M:updateTooltip()
	if not self.last_mz then
		game.tooltip_x = nil
		return
	end
	local mz = self.last_mz
	local str = self.tooltip(mz.item)
	if not self.no_tooltip then game:tooltipDisplayAtMap(mz.tx or (self.last_display_x + mz.x2), mz.ty or (self.last_display_y + mz.y1), str) end
end

function _M:moveSel(i, j)
	local match = nil

	if i == 0 then
		local t = self.tree[self.sel_i]
		if t.nodes then
			self.sel_j = util.bound(self.sel_j + j, 1, #t.nodes)
			match = t.nodes[self.sel_j]
		end
	elseif i == 1 then
		local t = self.tree[self.sel_i]
		if t.shown and self.sel_j == 0 and t.nodes and #t.nodes > 0 then
			self.sel_j = 1
			match = t.nodes[1]
		else
			self.sel_i = util.bound(self.sel_i + i, 1, #self.tree)
			self.sel_j = 0
			local t = self.tree[self.sel_i]
			match = t
		end
	elseif i == -1 then
		local t = self.tree[self.sel_i]
		if t.shown and self.sel_j > 0 and t.nodes and #t.nodes > 0 then
			self.sel_j = 0
			match = t
		else
			self.sel_i = util.bound(self.sel_i + i, 1, #self.tree)
			local t = self.tree[self.sel_i]
			if t.shown and t.nodes and #t.nodes > 0 then
				self.sel_j = 1
				match = t.nodes[1]
			else
				self.sel_j = 0
				match = t
			end
		end
	end

	if self.scrollbar and self.last_input_was_keyboard then
		local pos = 0
		for i = 1, #self.tree do
			tree = self.tree[i]
			pos = pos + tree.h
			-- we've reached selected row
			if self.sel_i == i then
				-- check if it was visible if not go scroll over there
				if pos - tree.h < self.scrollbar.pos then self.scrollbar.pos = util.minBound(pos - tree.h, 0, self.scrollbar.max)
				elseif pos > self.scrollbar.pos + self.h then self.scrollbar.pos = util.minBound(pos - self.h, 0, self.scrollbar.max)
				end
				break
			end
		end
	end
end

function _M:drawItem(item)
	if item.stat then
		local str = item:status():toString()
		local d = self.font:draw(str, self.font:size(str), 255, 255, 255, true)[1]
		item.text_status = d
	elseif item.type_stat then
		local str = item.name:toString()
		self.font:setStyle("bold")
		local d = self.font:draw(str, self.font:size(str), 255, 255, 255, true)[1]
		self.font:setStyle("normal")
		item.text_status = d
	elseif item.talent then
		local str = item:status():toString()
		local d = self.font:draw(str, self.font:size(str), 255, 255, 255, true)[1]
		item.text_status = d
	elseif item.type then
		local str = item:rawname():toString()
		local c = item:color()
		self.font:setStyle("bold")
		local d = self.font:draw(str, self.font:size(str), c[1], c[2], c[3], true)[1]
		self.font:setStyle("normal")
		item.text_status = d
		if ((not self.no_cross) and self.plus.w + 3 or 0) + item.text_status.w > self.w - (self.scrollbar and self.scrollbar.sel.w * 0.8 or 0) + 10 then
			item.text_status.display_offset = { x_dir = 0, x = 0 }
		end
	end
end

function _M:redrawAllItems()
	for i = 1, #self.tree do
		local tree = self.tree[i]
		self:drawItem(tree)
		for j = 1, #tree.nodes do
			local tal = tree.nodes[j]
			if not tal.texture then tal.texture = self:getImage(tal.entity.image):glTexture() end
			self:drawItem(tal)
		end
	end
end

function _M:on_select(item, force)
	if self.prev_item == item and not force then return end
	local str, fx, fy = self.tooltip(item)
	tx,ty = fx or (self.last_display_x + self.last_mz.x2), fy or (self.last_display_y + self.last_mz.y1)
	if not self.no_tooltip then game:tooltipDisplayAtMap(tx, ty, str) end
	self.prev_item = item
end

function _M:display(x, y, nb_keyframes, screen_x, screen_y, offset_x, offset_y, local_x, local_y, clip_area)
	nb_keyframes = (nb_keyframes or 0) * 0.5
	offset_x = offset_x or 0

	clip_area = clip_area or self.clip_area
	self.last_display_bx = x
	self.last_display_by = y
	self.last_display_x = screen_x
	self.last_display_y = screen_y

	local tmp_inertia = 0 -- used to correct selection frame position

	-- apply inertia to scrollbar
	if self.scrollbar then
		local tmp_pos = self.scrollbar.pos
		self.scrollbar.pos = util.minBound(self.scrollbar.pos + self.scroll_inertia, 0, self.scrollbar.max)
		tmp_inertia = self.scrollbar.pos - tmp_pos
		if self.scroll_inertia > 0 then self.scroll_inertia = math.max(self.scroll_inertia - 1, 0)
		elseif self.scroll_inertia < 0 then self.scroll_inertia = math.min(self.scroll_inertia + 1, 0)
		end
		if self.scrollbar.pos == 0 or self.scrollbar.pos == self.scrollbar.max then self.scroll_inertia = 0 end
	end

	offset_y = offset_y or (self.scrollbar and self.scrollbar.pos or 0)
	local_x = local_x or 0
	local_y = local_y or 0
	local loffset_y = offset_y - local_y
	local current_y = 0
	local current_x = 0
	local total_h = 0
	local clip_y_start = 0
	local clip_y_end = 0
	local clip_x_start = 0
	local clip_x_end = 0
	local frame_clip_y = 0
	local mz = {}
	local mx, my = self.mouse:getPos()
	local w = self.w - (self.scrollbar and self.scrollbar.sel.w * 0.8 or 0)

	self.mousezones = mz
	local dx, dy = 0, 0

	if self.last_mz then
		self:drawFrame(self.focused and self.frame_sel or self.frame_usel, x+self.last_mz.x1-2, y+self.last_mz.y1-2-tmp_inertia, 1, 1, 1, 1, self.last_mz.x2-self.last_mz.x1+4, self.last_mz.y2-self.last_mz.y1+4)
	end
	self.last_mz = nil

	for i = 1, #self.tree do
		local tree = self.tree[i]
		if total_h + tree.h > loffset_y and total_h < loffset_y + clip_area.h then
			local cross = not tree.shown and self.plus or self.minus
			local offset_h = 0

			dx = 0
			clip_y_start = 0
			clip_y_end = 0

			local tmp_dy = dy
			local key = tree.text_status

			--check if the talent category name and +/- icon are ready and fits into the screen
			if key then
				if total_h + key.h > loffset_y and total_h < loffset_y + clip_area.h then
					if not self.no_cross then
						util.clipTexture({_tex = cross.t, _tex_w = cross.tw, _tex_h = cross.th}, dx+x, dy + y + (key.h - cross.h) * 0.5, cross.w, cross.h, 0, total_h, 0, loffset_y, clip_area)
						dx = dx + cross.w + 3
					end
					
					if key.display_offset then
						if self.shadow then util.clipTexture(key, dx+x+2, dy+y+2, key.w, key.h, 0, total_h, key.display_offset.x, loffset_y, { w = w - cross.w, h = clip_area.h }, 0, 0, 0, self.shadow) end
						_, _, clip_y_start, clip_y_end = util.clipTexture(key, dx+x, dy+y, key.w, key.h, 0, total_h, key.display_offset.x, loffset_y, { w = w - cross.w, h = clip_area.h })
					else
						if self.shadow then util.clipTexture(key, dx+x+2, dy+y+2, key.w, key.h, 0, total_h, 0, loffset_y, clip_area, 0, 0, 0, self.shadow) end
						_, _, clip_y_start, clip_y_end = util.clipTexture(key, dx+x, dy+y, key.w, key.h, 0, total_h, 0, loffset_y, clip_area)
					end

					dy = dy + key.h - clip_y_start
					
					if (self.last_input_was_keyboard == false and mx > 0 and mx < w + 4 and my > tmp_dy and my < dy) or (self.last_input_was_keyboard == true and self.sel_i == i and self.sel_j == 0) then
						if key.display_offset then
							-- if we are going right
							if key.display_offset.x_dir == 0 then
								key.display_offset.x = key.display_offset.x + nb_keyframes
							-- if we are going left
							else
								key.display_offset.x = key.display_offset.x - nb_keyframes
							end

							-- if we would see too much to right then clip it and change dir
							if key.display_offset.x >= key.w - w + (self.no_cross and 0 or cross.w + 3) then
								key.display_offset.x_dir = 1
								key.display_offset.x = key.w - w + (self.no_cross and 0 or cross.w + 3)
							-- if we would see too much to left then clip it and change dir
							elseif key.display_offset.x <= 0 then
								key.display_offset.x_dir = 0
								key.display_offset.x = 0
							end
						end
						
						self.last_mz = {i = i, j = 1, item = tree, x1 = 0, y1 = tmp_dy, x2 = w + 4, y2 = dy}
						self:on_select(tree)
						self.sel_i = i
						self.sel_j = 0
					elseif key.display_offset then
						key.display_offset.x = 0
					end
				end
				total_h = total_h + key.h
			end
			offset_h = 4
			_, _, clip_y_start, clip_y_end = util.clipOffset(0, offset_h, 0, total_h, 0, loffset_y, clip_area)
			dy = dy + offset_h - clip_y_start
			total_h = total_h + offset_h

			dx = 0
			local addh = tree.shown and (self.frame_size + self.fh + 16) or 0

			tmp_dy = dy
			local tmp_total_h = total_h
			--if the talent category is expanded then display its talents
			if tree.shown and total_h + self.frame_size + self.fh + 16 > loffset_y then
				if not self.no_cross then dx = dx + cross.w + 3 end

				for j = 1, #tree.nodes do
					local tal = tree.nodes[j]
					addh = 0
					total_h = tmp_total_h
					dy = tmp_dy
					
					clip_y_start = 0
					clip_y_end = 0

					local do_shadow = util.getval(tal.do_shadow, tal) and 3 or 1
					if tal.texture and total_h + self.icon_size > loffset_y and total_h < loffset_y + clip_area.h then
						--talent icon
						_, _, clip_y_start, clip_y_end = util.clipTexture({_tex = tal.texture, _tex_w = self.icon_size, _tex_h = self.icon_size}, dx + x + self.icon_offset, dy + y + self.icon_offset, self.icon_size, self.icon_size, 0, total_h, 0, loffset_y, clip_area)
						if do_shadow > 1 then core.display.drawQuad(dx+x + self.icon_offset, dy+y + self.icon_offset, self.icon_size, self.icon_size - (clip_y_start + clip_y_end), 0, 0, 0, 200) end
					end
					
					clip_y_start = 0
					clip_y_end = 0
					if total_h + self.frame_size> loffset_y then
						--talent frame
						local rgb = tal:color()
						local one_by_max_color = 1 / (255 * do_shadow)
						_, _, clip_y_start, clip_y_end = self:drawFrame(self.talent_frame, dx+x, dy+y, rgb[1]*one_by_max_color, rgb[2]*one_by_max_color, rgb[3]*one_by_max_color, 1, nil, nil, 0, total_h, 0, loffset_y, clip_area)
						dy = dy + self.frame_size - clip_y_start
					end
					
					addh = self.frame_size
					total_h = tmp_total_h + self.frame_size
					
					offset_h = 2
					_, _, clip_y_start, clip_y_end = util.clipOffset(0, offset_h, 0, total_h, 0, loffset_y, clip_area)
					dy = dy + offset_h - clip_y_start
					addh = addh + offset_h
					total_h = total_h + offset_h

					clip_y_start = 0
					clip_y_end = 0
					local key = tal.text_status
					--and now we check if talent level text is visible
					if key then
						if total_h + key.h > loffset_y and total_h < loffset_y + clip_area.h  then
							--talent level text
							if self.shadow then util.clipTexture(key, dx+x + (self.frame_size - key.w) * 0.5 + 2, dy+y + 2, key.w, key.h, 0, total_h, 0, loffset_y, clip_area, 0, 0, 0, self.shadow) end
							_, _, clip_y_start, clip_y_end = util.clipTexture(key, dx+x + (self.frame_size - key.w)*0.5, dy+y, key.w, key.h, 0, total_h, 0, loffset_y, clip_area)
							dy = dy + key.h - clip_y_start
						end
						addh = addh + key.h
						total_h = total_h + key.h
					end

					offset_h = 10
					_, _, clip_y_start, clip_y_end = util.clipOffset(0, offset_h, 0, total_h, 0, loffset_y, clip_area)
					dy = dy + offset_h - clip_y_start
					addh = addh + offset_h

					if (self.last_input_was_keyboard == false and mx > dx and mx < dx + self.frame_size and my > tmp_dy and my < dy) or (self.last_input_was_keyboard == true and self.sel_i == i and self.sel_j == j) then
						self.last_mz = {i = i, j = j, item = tal, x1 = dx, y1 = tmp_dy, x2 = dx + self.frame_size, y2 = dy }
						self:on_select(tal)
						self.sel_i = i
						self.sel_j = j
					end

					dx = dx + self.frame_size + self.frame_offset
				end
			end
			total_h = tmp_total_h + addh
		else
			total_h = total_h + tree.h
		end
		-- if we are too deep then end this
		if total_h > loffset_y + clip_area.h then break end
	end

	if self.focused and self.scrollbar and self.max_h > self.h then
		self.scrollbar:display(x + self.w - self.scrollbar.w, y)
	end
end
