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
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(actor)
	self.actor = actor
	Dialog.init(self, "Quest Log for "..actor.name, game.w, game.h)

	self.c_desc = Textzone.new{width=math.floor(self.iw / 2 - 10), height=self.ih, text=""}

	self:generateList()

	self.c_list = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, scrollbar=true, sortable=true, columns={
		{name="Quest", width=70, display_prop="name", sort="name"},
		{name="Status", width=30, display_prop="status", sort="status_order"},
	}, list=self.list, fct=function(item) end, select=function(item, sel) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=0, ui=self.c_desc},
		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()
	self:select(self.list[1])
	self.c_list:selectColumn(2)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:select(item)
	if item and self.uis[2] then
		self.uis[2].ui = item.zone
	end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	for id, q in pairs(self.actor.quests or {}) do
		if true then
			local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=q:desc(self.actor)}
			local color = nil
			if q:isStatus(q.COMPLETED) then color = colors.simple(colors.LIGHT_GREEN)
			elseif q:isStatus(q.DONE) then color = colors.simple(colors.GREEN)
			elseif q:isStatus(q.FAILED) then color = colors.simple(colors.RED)
			end

			list[#list+1] = { zone=zone, name=q.name, quest=q, color = color, status=q.status_text[q.status], status_order=q.status }
		end
	end
	if game.turn then
		table.sort(list, function(a, b) return a.quest.gained_turn < b.quest.gained_turn end)
	else
		table.sort(list, function(a, b) return a.quest.name < b.quest.name end)
	end
	self.list = list
end
