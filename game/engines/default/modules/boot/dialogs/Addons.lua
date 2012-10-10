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
	Dialog.init(self, "Configure Addons", game.w * 0.8, game.h * 0.8)

	self.c_compat = Checkbox.new{default=false, width=math.floor(self.iw / 3 - 40), title="Show incompatible", on_change=function() self:switch() end}

	self:generateList()

	self.c_list = ListColumns.new{width=math.floor(self.iw / 3 - 10), height=self.ih - 10 - self.c_compat.h, scrollbar=true, columns={
		{name="Game Module", width=75, display_prop="name"},
		{name="Version", width=25, display_prop="version_txt"},
	}, list=self.list, fct=function(item) end, select=function(item, sel) self:select(item) end}

	self.c_adds = ListColumns.new{width=math.floor(self.iw * 2 / 3 - 10), height=self.ih - 10 - self.c_compat.h, scrollbar=true, columns={
		{name="Addon", width=60, display_prop="long_name"},
		{name="Active", width=20, display_prop=function(item)
			if item.dlc == "no" then
				return "#LIGHT_RED#Donator Status: Disabled"
			elseif config.settings.addons[item.for_module] and config.settings.addons[item.for_module][item.short_name] ~= nil then
				return (config.settings.addons[item.for_module][item.short_name] and "#LIGHT_GREEN#Manual: Active" or "#LIGHT_RED#Manual: Disabled"):toTString()
			else
				return (item.natural_compatible and "#LIGHT_GREEN#Auto: Active" or "#LIGHT_RED#Auto: Incompatible"):toTString()
			end
		end},
		{name="Version", width=20, display_prop="version_txt"},
	}, list={}, fct=function(item) self:switchAddon(item) end, select=function(item, sel) self:select(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=0, ui=self.c_adds},
		{left=0, bottom=0, ui=self.c_compat},
		{left=self.c_list.w + 5, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setFocus(self.c_list)
	self:setupUI()

--	self:select(self.list[1])

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:select(item)
	if item and item.adds and self.c_adds then
		self.c_adds:setList(item.adds)
	end
end

function _M:switchAddon(item)
	config.settings.addons[item.for_module] = config.settings.addons[item.for_module] or {}
	local v = config.settings.addons[item.for_module][item.short_name]
	if v == nil then config.settings.addons[item.for_module][item.short_name] = true
	elseif v == true then config.settings.addons[item.for_module][item.short_name] = false
	elseif v == false then config.settings.addons[item.for_module][item.short_name] = nil
	end
	self.c_adds:generateRow(item)

	local lines = {}
	lines[#lines+1] = ("addons = {}"):format(w)
	for mod, adds in pairs(config.settings.addons) do
		lines[#lines+1] = ("addons[%q] = {}"):format(mod)
		for k, v in pairs(adds) do
			lines[#lines+1] = ("addons[%q][%q] = %s"):format(mod, k, v and "true" or "false")
		end
	end

	game:saveSettings("addons", table.concat(lines, "\n"))
end

function _M:generateList()
	local list = Module:listModules(self.c_compat.checked)
	self.list = {}
	for i = 1, #list do
		for j, mod in ipairs(list[i].versions) do
			if j > 1 then break end
			if not mod.is_boot and (not mod.show_only_on_cheat or config.settings.cheat) then
				mod.name = tstring{{"font","bold"}, {"color","GOLD"}, mod.name, {"font","normal"}}
				mod.version_txt = ("%d.%d.%d"):format(mod.version[1], mod.version[2], mod.version[3])
				mod.adds = Module:listAddons(mod, true)

				table.insert(self.list, mod)
			end
		end
	end
end

function _M:switch()
	self:generateList()
	self.c_list:setList(self.list)
end
