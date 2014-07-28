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
local Base = require "engine.ui.Base"
local Focusable = require "engine.ui.Focusable"
local EquipDollFrame = require "engine.ui.EquipDollFrame"
local UIGroup = require "engine.ui.UIGroup"

module(..., package.seeall, class.inherit(Base, Focusable, UIGroup))

function _M:init(t)
	self.actor = assert(t.actor, "no equipdoll actor")
	self.drag_enable = t.drag_enable
	self.on_select = t.on_select
	self.fct = t.fct
	self.actorWear = t.actorWear
	self.filter = t.filter
	self.subobject = t.subobject
	self.subobject_restrict_slots = t.subobject_restrict_slots
	self.focus_ui = nil

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	self:generateEquipDollFrames()

	self.font_bold:setStyle("bold")
	local tw, th = self.font_bold:size(self.actor.name)
	local s = core.display.newSurface(tw, th)
	s:erase(0, 0, 0, 0)
	s:drawColorStringBlended(self.font_bold, self.actor.name, 0, 0, colors.GOLD.r, colors.GOLD.g, colors.GOLD.b, true)
	self.font_bold:setStyle("normal")
	self.charname_tex = {s:glTexture()}
	self.charname_tex.w = tw
	self.charname_tex.h = th

	self.inner_scroll = self:makeFrame("ui/tooltip/", self.w, self.h)

	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event)
		if self:mouseEvent(button, x, y, xrel, yrel, bx, by, event) then
			-- nothing, already done
		elseif button == "drag-end" and self.drag_enable then
			local drag = game.mouse.dragged.payload
			if drag.kind == "inventory" and drag.inven and self.actor:getInven(drag.inven) and not self.actor:getInven(drag.inven).worn then
				self:actorWear(drag.inven, drag.item_idx, drag.object)
				game.mouse:usedDrag()
			end
		end
	end)
	self.key:addBinds{
		ACCEPT = function() if self.focus_ui then self.focus_ui.ui.key:triggerVirtual("ACCEPT") end end,
	}
	self.key:addCommands{
		_UP = function() self:moveFocus(-1) end,
		_DOWN = function() self:moveFocus(1) end,
	}
end

function _M:keyTrigger(c)
	if self.chars and self.chars[c] then
		self.chars[c].ui.key:triggerVirtual("ACCEPT")
	end
end

function _M:on_focus_change(status)
	if status == true then
		game.tooltip:erase()
		local ui = self.focus_ui
		if self.on_select and ui then self.on_select(ui, ui.ui.inven, ui.ui.item, ui.ui:getItem()) end
	end
end

function _M:mouseEvent(button, x, y, xrel, yrel, bx, by, event)
	-- Look for focus
	for i = 1, #self.uis do
		local ui = self.uis[i]
		if ui.ui.can_focus and bx >= ui.x and bx <= ui.x + ui.ui.w and by >= ui.y and by <= ui.y + ui.ui.h then
			self:setInnerFocus(i)

			-- Pass the event
			ui.ui.mouse:delegate(button, bx, by, xrel, yrel, bx, by, event)
			return true
		end
	end
	self:no_focus()
end

function _M:getItem()
	if not self.focus_ui then return nil end
	return self.focus_ui.ui:getItem(), self.focus_ui.ui.inven, self.focus_ui.ui.item
end

function _M:generateEquipDollFrames()
	local doll = self.actor.equipdolls[self.actor.equipdoll or "default"]
	if not doll then return end

	local uis = {}
	local max_w = 0
	local max_h = 0

	for k, v in pairs(doll.list) do
		local inven = self.actor:getInven(k)
		if inven then
			for item, def in ipairs(v) do
				if item > inven.max then break end

				local frame = EquipDollFrame.new{actor=self.actor, inven=inven, name_pos=def.text, item=item, w=doll.w, h=doll.h, iw=doll.iw, ih=doll.ih, ix=doll.ix, iy=doll.iy, bg=doll.itemframe, bg_sel=doll.itemframe_sel, bg_empty=self.actor.inven_def[inven.name].infos and self.actor.inven_def[inven.name].infos.equipdoll_back, drag_enable=self.drag_enable}
				frame.doll_select = true
				frame.actorWear = function(_, ...) if self.actorWear then self.actorWear(frame, ...) end end
				frame.fct=function(button, event) if frame:getItem() and self.fct then self.fct({inven=inven, item=item, object=frame:getItem()}, button, event) end end
				frame.filter = self.filter
				frame.on_focus_change=function(status) local ui = self.focus_ui if self.on_select and ui then self.on_select(ui, ui.ui.inven, ui.ui.item, ui.ui:getItem()) end end
				uis[#uis+1] = {x=def.x, y=def.y, ui=frame, _weight=def.weight}
				
				if self.subobject and (not self.subobject_restrict_slots or (self.subobject_restrict_slots[inven.name] and self.subobject_restrict_slots[inven.name] >= item)) then
					local frame = EquipDollFrame.new{actor=self.actor, inven=inven, name_pos=def.text, item=item, w=math.ceil(doll.w/2), h=math.ceil(doll.h/2), iw=math.ceil(doll.iw/2), ih=math.ceil(doll.ih/2), ix=math.floor(doll.ix/2), iy=math.floor(doll.iy/2), bg=doll.itemframe, bg_sel=doll.itemframe_sel, bg_empty=self.actor.inven_def[inven.name].infos and self.actor.inven_def[inven.name].infos.equipdoll_back, drag_enable=self.drag_enable, subobject=self.subobject}
					frame.doll_select = true
					frame.secondary = true
					frame.no_name = true
					frame.actorWear = function(_, ...) if self.actorWear then self.actorWear(frame, ...) end end
					frame.fct=function(button, event) if frame:getItem() and self.fct then self.fct({inven=inven, item=item, object=frame:getItem()}, button, event) end end
					frame.filter = self.filter
					frame.on_focus_change=function(status) local ui = self.focus_ui if self.on_select and ui then self.on_select(ui, ui.ui.inven, ui.ui.item, ui.ui:getItem()) end end

					local dsx, dsy = doll.w + 3, 0
					if def.subshift == "up" then dsx, dsy = 0, -math.ceil(doll.h/2) - 3
					elseif def.subshift == "bottom" then dsx, dsy = 0, doll.h + 3
					elseif def.subshift == "left" then dsx, dsy = -math.ceil(doll.w/2) - 3, 0
					end

					uis[#uis+1] = {x=def.x + dsx, y=def.y + dsy, ui=frame, _weight=def.weight}
				end

				max_w = math.max(def.x, max_w)
				max_h = math.max(def.y, max_h)
			end
		end
	end

	table.sort(uis, function(a,b) return a._weight < b._weight end)

	self.w = max_w + math.floor(doll.w * 2.5)
	self.h = max_h + math.floor(doll.h * 2.5)
--	self.base_doll_y = (self.ih - self.h) / 2
	self.base_doll_y = 0

	self.chars = {}
	for i, ui in ipairs(uis) do
		ui.y = ui.y + self.base_doll_y
		ui.ui.mouse.delegate_offset_x = ui.x
		ui.ui.mouse.delegate_offset_y = ui.y
		self.chars[self:makeKeyChar(i)] = ui
	end

	self.uis = uis
	self:setFocus(1)
end

function _M:display(x, y, nb_keyframes, ox, oy)
	self.last_display_x = ox
	self.last_display_y = oy

	Base.drawFrame(self, self.inner_scroll, x, y + self.base_doll_y, 1, 1, 1, self.focused and 1 or 0.5)

	if self.title_shadow then self.charname_tex[1]:toScreenFull(x + (self.w - self.charname_tex.w) / 2 + 2, y + self.base_doll_y + 5 + 2, self.charname_tex.w, self.charname_tex.h, self.charname_tex[2], self.charname_tex[3], 0, 0, 0, 0.5) end
	self.charname_tex[1]:toScreenFull(x + (self.w - self.charname_tex.w) / 2, y + self.base_doll_y + 5, self.charname_tex.w, self.charname_tex.h, self.charname_tex[2], self.charname_tex[3])

	local doll = self.actor.equipdolls[self.actor.equipdoll or "default"]
	if not doll then return end

	self.actor:toScreen(nil, x + doll.doll_x, y + self.base_doll_y + doll.doll_y, 128, 128)

	-- UI elements
	for i = 1, #self.uis do
		local ui = self.uis[i]
		if not ui.hidden then ui.ui:display(x + ui.x, y + ui.y, nb_keyframes, ox + ui.x, oy + ui.y) end
	end
end
