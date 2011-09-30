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
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"
local EquipDollFrame = require "engine.ui.EquipDollFrame"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, actor, filter, action, on_select)
	self.action = action
	self.filter = filter
	self.actor = actor
	self.on_select = on_select

	Dialog.init(self, title or "Inventory", math.max(800, game.w * 0.8), math.max(600, game.h * 0.8))

	self.max_h = 0

	self.c_inven = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - self.max_h*self.font_h - 10, sortable=true, scrollbar=true, columns={
		{name="", width={20,"fixed"}, display_prop="char", sort="id"},
		{name="", width={24,"fixed"}, display_prop="object", sort="sortname", direct_draw=function(item, x, y) if item.object then item.object:toScreen(nil, x+4, y, 16, 16) end end},
		{name="Inventory", width=72, display_prop="name", sort="sortname"},
		{name="Category", width=20, display_prop="cat", sort="cat"},
		{name="Enc.", width=8, display_prop="encumberance", sort="encumberance"},
	}, list={}, fct=function(item, sel, button, event) self:use(item, button, event) end, select=function(item, sel) self:select(item) end, on_drag=function(item) self:onDrag(item) end, on_drag_end=function() self:onDragTakeoff() end}

	local uis = self:generateEquipDollFrames()
	self:generateList()

	uis[#uis+1] = {right=0, top=0, ui=self.c_inven}
	uis[#uis+1] = {hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}}

	self:loadUI(uis)
	self:setFocus(self.c_inven)
	self:setupUI()

	self.key:addCommands{
		__TEXTINPUT = function(c)
			local list
			if self.focus_ui and self.focus_ui.ui == self.c_inven then list = self.c_inven.list
			elseif self.focus_ui and self.focus_ui.ui == self.c_equip then list = self.c_equip.list
			end
			if list and list.chars[c] then
				self:use(list[list.chars[c]])
			end
		end,
	}
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
			if self.focus_ui and self.focus_ui.ui == self.c_inven then self:use(self.c_inven.list[self.c_inven.sel])
			elseif self.focus_ui and self.focus_ui.ui == self.c_equip then self:use(self.c_equip.list[self.c_equip.sel])
			end
		end,
		EXIT = function() game:unregisterDialog(self) end,
	}

	-- Add tooltips
	self.on_select = function(item)
		if item.last_display_x and item.object then
			game:tooltipDisplayAtMap(item.last_display_x, item.last_display_y, item.object:getDesc({do_color=true}, self.actor:getInven(item.object:wornInven())))
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
	if self.focus_ui and self.focus_ui.ui == self.c_inven then item = self.c_inven.list[self.c_inven.sel]
	elseif self.focus_ui and self.focus_ui.ui == self.c_equip then item = self.c_equip.list[self.c_equip.sel]
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
	if self.focus_ui and self.focus_ui.ui == self.c_inven then self:select(self.c_inven.list[self.c_inven.sel])
	elseif self.focus_ui and self.focus_ui.ui and self.focus_ui.ui.doll_select and self.focus_ui.ui.inven[self.focus_ui.ui.item] then
		self:select{last_display_x=self.focus_ui.ui.last_display_x+self.focus_ui.ui.w, last_display_y=self.focus_ui.ui.last_display_y, object=self.focus_ui.ui.inven[self.focus_ui.ui.item]}
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

function _M:generateEquipDollFrames()
	local doll = self.actor.equipdolls[self.actor.equipdoll or "default"]
	if not doll then return end

	local uis = {}

	for k, v in pairs(doll.list) do
		local inven = self.actor:getInven(k)
		if inven then
			for item, def in ipairs(v) do
				local frame = EquipDollFrame.new{actor=self.actor, inven=inven, item=item, w=doll.w, h=doll.h, iw=doll.iw, ih=doll.ih, ix=doll.ix, iy=doll.iy, bg=doll.itemframe, bg_sel=doll.itemframe_sel, bg_empty=self.actor.inven_def[inven.name].infos and self.actor.inven_def[inven.name].infos.equipdoll_back, drag_enable=true}
				frame.doll_select = true
				frame.actorWear = function(_, ...)
					if inven[item] then self.actor:doTakeoff(inven, item, inven[item]) end
					self.actor:doWear(...)
					self:generateList()
				end
				frame.fct=function(button, event) if inven[item] then self:use({inven=inven, item=item, object=inven[item]}, button, event) end end
				uis[#uis+1] = {left=def.x, top=def.y, ui=frame}
			end
		end
	end
	return uis
end

function _M:innerDisplayBack(x, y, nb_keyframes)
	local doll = self.actor.equipdolls[self.actor.equipdoll or "default"]
	if not doll then return end

	self.actor:toScreen(nil, x + doll.doll_x, y + doll.doll_y, 128, 128)
end

function _M:generateList(no_update)
	-- Makes up the list
	self.inven_list = {}
	local list = self.inven_list
	local chars = {}
	local i = 1
	for item, o in ipairs(self.actor:getInven("INVEN") or {}) do
		if not self.filter or self.filter(o) then
			local char = self:makeKeyChar(i)

			local enc = 0
			o:forAllStack(function(o) enc=enc+o.encumber end)

			list[#list+1] = { id=#list+1, char=char, name=o:getName(), sortname=o:getName():toString():removeColorCodes(), color=o:getDisplayColor(), object=o, inven=self.actor.INVEN_INVEN, item=item, cat=o.subtype, encumberance=enc, desc=o:getDesc() }
			chars[char] = #list
			i = i + 1
		end
	end
	list.chars = chars

	if not no_update then
		self.c_inven:setList(self.inven_list)
	end
end

function _M:on_recover_focus()
	self:generateList()
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
	if item and item.object then
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
	print(table.serialize(drag,nil,true))
	if drag.kind == "inventory" and drag.inven and self.actor:getInven(drag.inven) and self.actor:getInven(drag.inven).worn then
		self.actor:doTakeoff(drag.inven, drag.item_idx, drag.object)
		self:generateList()
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
