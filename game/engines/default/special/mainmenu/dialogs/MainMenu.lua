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
local List = require "engine.ui.List"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "Main Menu", 300, 400, 450, 50)

	self.list = {
		{name="New Game", fct=function() game:registerDialog(require("special.mainmenu.dialogs.NewGame").new()) end},
		{name="Load Game", fct=function() game:registerDialog(require("special.mainmenu.dialogs.LoadGame").new()) end},
		{name="Player Profile", fct=function() game:registerDialog(require("special.mainmenu.dialogs.Profile").new()) end},
--		{name="Install Module", fct=function() end},
		{name="Options", fct=function()
			local menu menu = require("engine.dialogs.GameMenu").new{
				"resume",
				"keybinds_all",
				"video",
				"resolution",
				"sound",
			}
			game:registerDialog(menu)
		end},
		{name="Exit", fct=function() game:onQuit() end},
	}

	self.c_list = List.new{width=self.iw, nb_items=#self.list, list=self.list, fct=function(item) end, font={"/data/font/VeraBd.ttf", 16}}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
	}
	self:setupUI(false, true)
end

function _M:on_recover_focus()
	game:unregisterDialog(self)
	local d = new()
	d.__showup = false
	game:registerDialog(d)
end
