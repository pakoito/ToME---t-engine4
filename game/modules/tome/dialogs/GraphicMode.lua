-- ToME - Tales of Middle-Earth
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
local List = require "engine.ui.List"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	self:generateList()

	Dialog.init(self, "Change graphic mode", 300, 20)

	self.c_list = List.new{width=self.iw, nb_items=#self.list, list=self.list, fct=function(item) self:use(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
	}
	self:setFocus(self.c_list)
	self:setupUI(false, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:use(item)
	if not item then return end
	game.gfxmode = item.mode
	game:setupDisplayMode()
	game:unregisterDialog(self)
end

function _M:generateList()
	local list = {
		{name="32x32 Graphical",		mode=1},
		{name="16x16 Graphical",		mode=2},
		{name="32x32 ASCII",			mode=3},
		{name="16x16 ASCII",			mode=4},
		{name="32x32 ASCII with background",	mode=5},
		{name="16x16 ASCII with background",	mode=6},
	}
	self.list = list
end
