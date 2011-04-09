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
local TextzoneList = require "engine.ui.TextzoneList"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(title, player)
	self.player = player
	local total = #world.achiev_defs
	local nb = 0
	for id, data in pairs(world.achieved) do nb = nb + 1 end

	Dialog.init(self, (title or "Achievements").." ("..nb.."/"..total..")", game.w * 0.8, game.h * 0.8)

	self.c_desc = TextzoneList.new{width=math.floor(self.iw / 2 - 10), height=self.ih}

	self:generateList()

	self.c_list = ListColumns.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, scrollbar=true, sortable=true, columns={
		{name="Achievement", width=60, display_prop="name", sort="name"},
		{name="When", width=20, display_prop="when", sort="when"},
		{name="Who", width=20, display_prop="who", sort="who"},
	}, list=self.list, fct=function(item) end, select=function(item, sel) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=0, ui=self.c_desc},
		{hcenter=0, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:select(item)
	if item then
		local also = ""
		if self.player and self.player.achievements and self.player.achievements[item.id] then
			also = "#GOLD#Also achieved by your current character#LAST#\n"
		end
		self.c_desc:switchItem(item, ("#GOLD#Achieved on:#LAST# %s\n#GOLD#Achieved by:#LAST# %s\n%s\n#GOLD#Description:#LAST# %s"):format(item.when, item.who, also, item.desc))
	end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local i = 0
	for id, data in pairs(world.achieved) do
		local a = world:getAchievementFromId(id)
		local color = nil
		if self.player and self.player.achievements and self.player.achievements[id] then
			color = colors.simple(colors.LIGHT_GREEN)
		end
		list[#list+1] = { name=a.name, color=color, desc=a.desc, when=data.when, who=data.who, order=a.order, id=id }
		i = i + 1
	end
	table.sort(list, function(a, b) return a.name < b.name end)
	self.list = list
end
