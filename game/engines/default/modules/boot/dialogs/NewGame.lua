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
local Module = require "engine.Module"
local Dialog = require "engine.ui.Dialog"
local ListColumns = require "engine.ui.ListColumns"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local Checkbox = require "engine.ui.Checkbox"
local Button = require "engine.ui.Button"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "New Game", game.w * 0.8, game.h * 0.8)

	self.c_desc = Textzone.new{width=math.floor(self.iw / 3 * 2 - 10), height=self.ih, text=""}

	self.c_switch = Checkbox.new{default=false, width=math.floor(self.iw / 3 - 40), title="Show all versions", on_change=function() self:switch() end}
	self.c_compat = Checkbox.new{default=false, width=math.floor(self.iw / 3 - 40), title="Show incompatible", on_change=function() self:switch() end}

	self:generateList()

	self.c_list = ListColumns.new{width=math.floor(self.iw / 3 - 10), height=self.ih - 10 - self.c_switch.h - self.c_compat.h, scrollbar=true, columns={
		{name="Game Module", width=80, display_prop="name"},
		{name="Version", width=20, display_prop="version_txt"},
	}, list=self.list, fct=function(item) end, select=function(item, sel) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=0, ui=self.c_desc},
		{left=0, bottom=self.c_compat.h, ui=self.c_switch},
		{left=0, bottom=0, ui=self.c_compat},
		{left=self.c_list.w + 5, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

	self:select(self.list[1])

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:on_register()
	if #self.list == 1 then
		game:unregisterDialog(self)
		self.list[1]:fct()
	end
end

function _M:select(item)
	if item and self.uis[2] then
		self.uis[2].ui = item.zone
	end
end

function _M:generateList()
	local list = Module:listModules(self.c_compat.checked)
	self.list = {}
	for i = 1, #list do
		for j, mod in ipairs(list[i].versions) do
			if not self.c_switch.checked and j > 1 then break end
			if not mod.is_boot and (not mod.show_only_on_cheat or config.settings.cheat) then
				mod.name = tstring{{"font","bold"}, {"color","GOLD"}, mod.name, {"font","normal"}}
				mod.fct = function(mod)
					if mod.no_get_name then
						Module:instanciate(mod, "player", true, false)
					else
						game:registerDialog(require('engine.dialogs.GetText').new("Enter your character's name", "Name", 2, 25, function(text)
							local savename = text:gsub("[^a-zA-Z0-9_-.]", "_")
							if fs.exists(("/%s/save/%s/game.teag"):format(mod.short_name, savename)) then
								Dialog:yesnoPopup("Overwrite character?", "There is already a character with this name, do you want to overwrite it?", function(ret)
									if not ret then Module:instanciate(mod, text, true) end
								end, "No", "Yes")
							else
								Module:instanciate(mod, text, true)
							end
						end))
					end
				end
				mod.version_txt = ("%d.%d.%d"):format(mod.version[1], mod.version[2], mod.version[3])
				local tstr = tstring{{"font","bold"}, {"color","GOLD"}, mod.long_name, true, true}
				if mod.incompatible then tstr:add({"font","bold"}, {"color","LIGHT_RED"}, "This game is not compatible with your version of T-Engine, you can still try it but it might break.", true, true) end
				tstr:add({"font","normal"}, {"color","WHITE"})
				tstr:merge(mod.description:toTString())
				mod.zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=tstr}

				table.insert(self.list, mod)
			end
		end
	end
end

function _M:switch()
	self:generateList()
	self.c_list.list = self.list
	self.c_list:generate()
end
