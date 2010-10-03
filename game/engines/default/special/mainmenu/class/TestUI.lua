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
require "engine.Game"
require "engine.KeyBind"
require "engine.interface.GameMusic"
local Module = require "engine.Module"
local Savefile = require "engine.Savefile"
local Tooltip = require "engine.Tooltip"
local ButtonList = require "engine.ButtonList"
local DownloadDialog = require "engine.dialogs.DownloadDialog"

local List = require "engine.ui.List"
local ListColumns = require "engine.ui.ListColumns"
local Button = require "engine.ui.Button"
local Textzone = require "engine.ui.Textzone"
local Textbox = require "engine.ui.Textbox"
local TreeList = require "engine.ui.TreeList"
local Dialog = require "engine.ui.Dialog"

module(..., package.seeall, class.inherit(engine.Game, engine.interface.GameMusic))

function _M:init()
	engine.Game.init(self, engine.KeyBind.new())

	self.refuse_threads = true

	local tree = TreeList.new{width=390, height=200, sortable=true, scrollbar=true, all_clicks=true, columns={
		{width=90, display_prop="name", sort="name"},
		{width=10, display_prop="val", sort="val"},
	}, tree={
		{name="#{bold}#Node 1#{normal}#", val="plop", shown=true, nodes={
			{name="toto", val=20},
			{name="tutu", val=50},
			{name="plopzor #GOLD#Robe of the Archmage#WHITE#!", val=20},
			{name="MOUHAHAHAHAH!", val=20},
		}},
		{name="#{bold}#Node 2#{normal}#", val="plop", shown=false, nodes={
			{name="toto", val=20},
			{name="tutu", val=50},
			{name="plopzor #GOLD#Robe of the Archmage#WHITE#!", val=20},
		}},
		{name="#{bold}#Node 3#{normal}#", val="plop", shown=true, nodes={
			{name="MOUHAHAHAHAH!", val=20},
			{name="toto", val=20},
			{name="tutu", val=50},
			{name="plopzor #GOLD#Robe of the Archmage#WHITE#!", val=20},
			{name="MOUHAHAHAHAH!", val=20},
			{name="toto", val=20},
		}},
		{name="#{bold}#Node 4#{normal}#", val="plop", shown=true, nodes={
			{name="tutu", val=50},
			{name="plopzor #GOLD#Robe of the Archmage#WHITE#!", val=20},
			{name="MOUHAHAHAHAH!", val=20},
		}},
	}, fct=function(self, item, sel, v)
		if item.nodes then
			item.shown = not item.shown
			self:drawItem(item)
			self:outputList()
		else
			item.val = item.val + (v == "left" and 1 or -1)
			self:drawItem(item)
		end
	end}

	local d = Dialog.new("Test UI", 800, 500)
	d:loadUI{
		{left=0, top=0, ui=tree},
	}
	d:setupUI()
	self:registerDialog(d)
end

function _M:run()
	self:setCurrent()
end

function _M:tick()
	return true
end

function _M:display()
	engine.Game.display(self)
end

--- Skip to a module directly ?
function _M:commandLineArgs(args)
end

--- Ask if we realy want to close, if so, save the game first
function _M:onQuit()
	os.exit()
end

