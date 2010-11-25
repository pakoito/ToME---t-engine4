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
local Module = require "engine.Module"
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local Button = require "engine.ui.Button"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "New Game", game.w, game.h)

	self.c_desc = Textzone.new{width=math.floor(self.iw / 3 * 2 - 10), height=self.ih, text=""}

	self.c_switch = Button.new{width=math.floor(self.iw / 3 - 40), text="Show all versions", fct=function() self:switchVersions() end}

	self:generateList()

	self.c_list = ListColumns.new{width=math.floor(self.iw / 3 - 10), height=self.ih - 10 - self.c_switch.h, scrollbar=true, columns={
		{name="Game Module", width=80, display_prop="name"},
		{name="Version", width=20, display_prop="version_txt"},
	}, list=self.list, fct=function(item) end, select=function(item, sel) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=0, ui=self.c_desc},
		{left=0, bottom=0, ui=self.c_switch},
		{left=self.c_list.w + 5, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self:select(self.list[1])

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
	local list = Module:listModules()
	self.list = {}
	for i = 1, #list do
		for j, mod in ipairs(list[i].versions) do
			if not self.all_versions and j > 1 then break end
			if not mod.is_boot then
				mod.name = tstring{{"font","bold"}, {"color","GOLD"}, mod.name, {"font","normal"}}
				mod.fct = function(mod)
					if mod.no_get_name then
						Module:instanciate(mod, "player", true)
					else
						game:registerDialog(require('engine.dialogs.GetText').new("Enter your character's name", "Name", 2, 25, function(text)
							Module:instanciate(mod, text, true)
						end))
					end
				end
				mod.version_txt = ("%d.%d.%d"):format(mod.version[1], mod.version[2], mod.version[3])
				mod.zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text="#{bold}##GOLD#"..mod.long_name.."#WHITE##{normal}#\n\n"..mod.description}

				table.insert(self.list, mod)
			end
		end
	end
end

function _M:switchVersions()
	self.all_versions = not self.all_versions
	self:generateList()
	self.c_list.list = self.list
	self.c_list:generate()
	self.c_switch.text = self.all_versions and "Show only new versions" or "Show all versions"
	self.c_switch:generate()
end
