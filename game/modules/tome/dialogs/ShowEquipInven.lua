-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
local Dialog = require "engine.ui.Dialog"
local Inventory = require "engine.ui.Inventory"
local Separator = require "engine.ui.Separator"
local EquipDoll = require "engine.ui.EquipDoll"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, actor, filter, action, on_select)
	self.action = action
	self.filter = filter
	self.actor = actor
	self.on_select = on_select

	Dialog.init(self, title or "Inventory", math.max(800, game.w * 0.8), math.max(600, game.h * 0.8))

	self.c_doll = EquipDoll.new{actor=actor, drag_enable=true,
		fct = function(item, button, event) self:use(item, button, event) end,
		on_select = function(ui, inven, item, o) if ui.ui.last_display_x then self:select{last_display_x=ui.ui.last_display_x+ui.ui.w, last_display_y=ui.ui.last_display_y, object=o} end end,
		actorWear = function(ui, ...)
			if ui:getItem() then self.actor:doTakeoff(ui.inven, ui.item, ui:getItem(), true) end
			self.actor:doWear(...)
			self.c_inven:generateList()
		end
	}

	self.c_inven = Inventory.new{actor=actor, inven=actor:getInven("INVEN"), width=self.iw - 20 - self.c_doll.w, height=self.ih - 10,
		fct=function(item, sel, button, event) self:use(item, button, event) end,
		on_select=function(item, sel) self:select(item) end,
		on_drag=function(item) self:onDrag(item) end,
		on_drag_end=function() self:onDragTakeoff() end,
	}

	local uis = {
		{left=0, top=0, ui=self.c_doll},
		{right=0, top=0, ui=self.c_inven},
		{left=self.c_doll.w, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}

	self:loadUI(uis)
	self:setFocus(self.c_inven)
	self:setupUI()

	self.key:addBinds{
		HOTKEY_1 = function() self:defineHotkey(1) end,
		HOTKEY_2 = function() self:defineHotkey(2) end,
		HOTKEY_3 = function() self:defineHotkey(3) end,
		HOTKEY_4 = function() self:defineHotkey(4) end,
		HOTKEY_5 = function() self:defineHotkey(5) end,
		HOTKEY_6 = function() self:defineHotkey(6) end,
		HOTKEY_7 = function() self:defineHotkey(7) end,
		HOTKEY_8 = function() self:defineHotkey(8) end,
		HOTKEY_9 = function() self:defineHotkey(9) end,
		HOTKEY_10 = function() self:defineHotkey(10) end,
		HOTKEY_11 = function() self:defineHotkey(11) end,
		HOTKEY_12 = function() self:defineHotkey(12) end,
		HOTKEY_SECOND_1 = function() self:defineHotkey(13) end,
		HOTKEY_SECOND_2 = function() self:defineHotkey(14) end,
		HOTKEY_SECOND_3 = function() self:defineHotkey(15) end,
		HOTKEY_SECOND_4 = function() self:defineHotkey(16) end,
		HOTKEY_SECOND_5 = function() self:defineHotkey(17) end,
		HOTKEY_SECOND_6 = function() self:defineHotkey(18) end,
		HOTKEY_SECOND_7 = function() self:defineHotkey(19) end,
		HOTKEY_SECOND_8 = function() self:defineHotkey(20) end,
		HOTKEY_SECOND_9 = function() self:defineHotkey(21) end,
		HOTKEY_SECOND_10 = function() self:defineHotkey(22) end,
		HOTKEY_SECOND_11 = function() self:defineHotkey(23) end,
		HOTKEY_SECOND_12 = function() self:defineHotkey(24) end,
		HOTKEY_THIRD_1 = function() self:defineHotkey(25) end,
		HOTKEY_THIRD_2 = function() self:defineHotkey(26) end,
		HOTKEY_THIRD_3 = function() self:defineHotkey(27) end,
		HOTKEY_THIRD_4 = function() self:defineHotkey(28) end,
		HOTKEY_THIRD_5 = function() self:defineHotkey(29) end,
		HOTKEY_THIRD_6 = function() self:defineHotkey(30) end,
		HOTKEY_THIRD_7 = function() self:defineHotkey(31) end,
		HOTKEY_THIRD_8 = function() self:defineHotkey(32) end,
		HOTKEY_THIRD_9 = function() self:defineHotkey(33) end,
		HOTKEY_THIRD_10 = function() self:defineHotkey(34) end,
		HOTKEY_THIRD_11 = function() self:defineHotkey(35) end,
		HOTKEY_THIRD_12 = function() self:defineHotkey(36) end,
		HOTKEY_FOURTH_1 = function() self:defineHotkey(37) end,
		HOTKEY_FOURTH_2 = function() self:defineHotkey(38) end,
		HOTKEY_FOURTH_3 = function() self:defineHotkey(39) end,
		HOTKEY_FOURTH_4 = function() self:defineHotkey(40) end,
		HOTKEY_FOURTH_5 = function() self:defineHotkey(41) end,
		HOTKEY_FOURTH_6 = function() self:defineHotkey(42) end,
		HOTKEY_FOURTH_7 = function() self:defineHotkey(43) end,
		HOTKEY_FOURTH_8 = function() self:defineHotkey(44) end,
		HOTKEY_FOURTH_9 = function() self:defineHotkey(45) end,
		HOTKEY_FOURTH_10 = function() self:defineHotkey(46) end,
		HOTKEY_FOURTH_11 = function() self:defineHotkey(47) end,
		HOTKEY_FOURTH_12 = function() self:defineHotkey(48) end,
		ACCEPT = function()
			if self.focus_ui and self.focus_ui.ui == self.c_inven then self:use(self.c_inven.c_inven.list[self.c_inven.c_inven.sel])
			end
		end,
		EXIT = function() game:unregisterDialog(self) end,
	}

	-- Add tooltips
	self.on_select = function(item)
		if item.last_display_x and item.object then
			game:tooltipDisplayAtMap(item.last_display_x, item.last_display_y, item.object:getDesc({do_color=true}))
		elseif item.last_display_x and item.data and item.data.desc then
			game:tooltipDisplayAtMap(item.last_display_x, item.last_display_y + self.c_tabs.h, item.data.desc)
		end
	end
	self.key.any_key = function(sym)
		-- Control resets the tooltip
		if sym == self.key._LCTRL or sym == self.key._RCTRL then local i = self.cur_item self.cur_item = nil self:select(i) end
	end
end

function _M:on_register()
	game:onTickEnd(function() self.key:unicodeInput(true) end)
end

function _M:defineHotkey(id)
	if not self.actor or not self.actor.hotkey then return end

	local item = nil
	if self.focus_ui and self.focus_ui.ui == self.c_inven then item = self.c_inven.c_inven.list[self.c_inven.c_inven.sel]
	elseif self.focus_ui and self.focus_ui.ui == self.c_doll then item = {object=self.c_doll:getItem()}
	end
	if not item or not item.object then return end

	self.actor.hotkey[id] = {"inventory", item.object:getName{no_add_name=true, no_count=true}}
	self:simplePopup("Hotkey "..id.." assigned", item.object:getName{no_add_name=true, no_count=true}:capitalize().." assigned to hotkey "..id)
	self.actor.changed = true
end

function _M:select(item)
	if self.cur_item == item then return end
	if item then
		if self.on_select then self.on_select(item) end
	end
	self.cur_item = item
end

function _M:on_focus(id, ui)
	if self.focus_ui and self.focus_ui.ui == self.c_inven then self:select(self.c_inven.c_inven.list[self.c_inven.c_inven.sel])
	elseif self.focus_ui and self.focus_ui.ui == self.c_tabs then
	else
		game.tooltip_x = nil
	end
end
function _M:no_focus()
	game.tooltip_x = nil
end

function _M:use(item, button, event)
	if item then
		if self.action(item.object, item.inven, item.item, button, event) then
			game:unregisterDialog(self)
		end
	end
end

function _M:on_recover_focus()
	self.c_inven:generateList()
end

function _M:unload()
	for inven_id = 1, #self.actor.inven_def do if self.actor.inven[inven_id] then for item, o in ipairs(self.actor.inven[inven_id]) do o.__new_pickup = nil end end end
end

function _M:updateTitle(title)
	Dialog.updateTitle(self, title)

	local green = colors.LIGHT_GREEN
	local red = colors.LIGHT_RED

	local enc, max = self.actor:getEncumbrance(), self.actor:getMaxEncumbrance()
	local v = math.min(enc, max) / max
	self.title_fill = self.iw * v
	self.title_fill_color = {
		r = util.lerp(green.r, red.r, v),
		g = util.lerp(green.g, red.g, v),
		b = util.lerp(green.b, red.b, v),
	}
end

function _M:onDrag(item)
	if item and item.object and not item.object.__transmo then
		local s = item.object:getEntityFinalSurface(nil, 64, 64)
		local x, y = core.mouse.get()
		game.mouse:startDrag(x, y, s, {kind="inventory", item_idx=item.item, inven=item.inven, object=item.object, id=item.object:getName{no_add_name=true, force_id=true, no_count=true}}, function(drag, used)
			if not used then
				local x, y = core.mouse.get()
				game.mouse:receiveMouse("drag-end", x, y, true, nil, {drag=drag})
			end
		end)
	end
end

function _M:onDragTakeoff()
	local drag = game.mouse.dragged.payload
	if drag.kind == "inventory" and drag.inven and self.actor:getInven(drag.inven) and self.actor:getInven(drag.inven).worn then
		self.actor:doTakeoff(drag.inven, drag.item_idx, drag.object)
		self.c_inven:generateList()
		game.mouse:usedDrag()
	end
end

function _M:drawFrame(x, y, r, g, b, a)
	Dialog.drawFrame(self, x, y, r, g, b, a)
	if r == 0 then return end -- Drawing the shadow
	if self.ui ~= "metal" then return end
	if not self.title_fill then return end

	core.display.drawQuad(x + self.frame.title_x, y + self.frame.title_y, self.title_fill, self.frame.title_h, self.title_fill_color.r, self.title_fill_color.g, self.title_fill_color.b, 60)
end

function _M:generateList()
	self.c_inven:generateList()
end
