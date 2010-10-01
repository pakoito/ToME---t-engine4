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

local ListColumns = require "engine.ui.ListColumns"
local Button = require "engine.ui.Button"
local Dialog = require "engine.ui.Dialog"

module(..., package.seeall, class.inherit(engine.Game, engine.interface.GameMusic))

function _M:init()
	engine.Game.init(self, engine.KeyBind.new())

	self.refuse_threads = true

	local b1 = Button.new{text="Ok", fct=function() print"OK" end}
	local b2 = Button.new{text="Cancel", fct=function() print"KO" end}
	local list = ListColumns.new{width=200, height=200, columns={
		{name="Name", width=150}, {name="Encumber", width=50},
	}, list={
		{name="toto", encumberance="20"},
		{name="tutu", encumberance="50"},
		{name="plopzor #GOLD#Robe of the Archmage#WHITE#!", encumberance="20"},
		{name="MOUHAHAHAHAH!", encumberance="20"},
		{name="toto", encumberance="20"},
		{name="tutu", encumberance="50"},
		{name="plopzor #GOLD#Robe of the Archmage#WHITE#!", encumberance="20"},
		{name="MOUHAHAHAHAH!", encumberance="20"},
		{name="toto", encumberance="20"},
		{name="tutu", encumberance="50"},
		{name="plopzor #GOLD#Robe of the Archmage#WHITE#!", encumberance="20"},
		{name="MOUHAHAHAHAH!", encumberance="20"},
		{name="toto", encumberance="20"},
		{name="tutu", encumberance="50"},
		{name="plopzor #GOLD#Robe of the Archmage#WHITE#!", encumberance="20"},
		{name="MOUHAHAHAHAH!", encumberance="20"},
	}, fct=function(item) print(item.name) end}

	local d = Dialog.new("Test UI", 400, 300)
	d:loadUI{
		{left=0, top=0, ui=list},
		{left=10, bottom=10, ui=b1},
		{right=10, bottom=10, ui=b2},
	}
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

