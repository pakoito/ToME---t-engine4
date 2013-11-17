-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
local TreeList = require "engine.ui.TreeList"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"
local GetQuantity = require "engine.dialogs.GetQuantity"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "Steam Options", game.w * 0.8, game.h * 0.8)

	self.c_desc = Textzone.new{width=math.floor(self.iw / 2 - 10), height=self.ih, text=""}

	self:generateList()

	self.c_list = TreeList.new{width=math.floor(self.iw / 2 - 10), height=self.ih - 10, scrollbar=true, columns={
		{width=60, display_prop="name"},
		{width=40, display_prop="status"},
	}, tree=self.list, fct=function(item) end, select=function(item, sel) self:select(item) end}

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
	if item and self.uis[2] then
		self.uis[2].ui = item.zone
	end
end

function _M:purgeCloud()
	local oldns = core.steam.getFileNamespace()
	core.steam.setFileNamespace("")
	local list = core.steam.listFilesEndingWith("")
	for _, file in ipairs(list) do
		core.steam.deleteFile(file)
	end
	core.steam.setFileNamespace(oldns)
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local i = 0

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Enable Steam Cloud saves.\nYour saves will be put on steam cloud and always be availwable everywhere.\nDisable if you have bandwidth limitations.#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Cloud Saves#WHITE##{normal}#", status=function(item)
		return tostring(core.steam.isCloudEnabled(true) and "enabled" or "disabled")
	end, fct=function(item)
		core.steam.cloudEnable(not core.steam.isCloudEnabled(true))
		self.c_list:drawItem(item)
	end,}

	local zone = Textzone.new{width=self.c_desc.w, height=self.c_desc.h, text=string.toTString"Purge all Steam Cloud saves.\nThis will remove all saves from the cloud cloud (but not your local copy). Only use if you somehow encounter storage problems on it (which should not happen, the game automatically manages it for you).#WHITE#"}
	list[#list+1] = { zone=zone, name=string.toTString"#GOLD##{bold}#Purge Cloud Saves#WHITE##{normal}#", status=function(item)
		return "purge"
	end, fct=function(item)
		Dialog:yesnoPopup("Steam Cloud Purge", "Confirm purge?", function(ret) if ret then
			self:purgeCloud()
			Dialog:simplePopup("Steam Cloud Purge", "All data purged from the cloud.")
		end end)
	end,}

	self.list = list
end
