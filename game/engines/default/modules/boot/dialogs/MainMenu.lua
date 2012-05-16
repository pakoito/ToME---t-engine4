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
local Dialog = require "engine.ui.Dialog"
local List = require "engine.ui.List"
local Button = require "engine.ui.Button"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "Main Menu", 300, 400, 450, 50)
	self.__showup = false
	self.absolute = true

	local l = {}
	self.list = l
	l[#l+1] = {name="New Game", fct=function() game:registerDialog(require("mod.dialogs.NewGame").new()) end}
	l[#l+1] = {name="Load Game", fct=function() game:registerDialog(require("mod.dialogs.LoadGame").new()) end}
	l[#l+1] = {name="View High Scores", fct=function() game:registerDialog(require("mod.dialogs.ViewHighScores").new()) end}
	l[#l+1] = {name="Addons", fct=function() game:registerDialog(require("mod.dialogs.Addons").new()) end}
--	if config.settings.install_remote then l[#l+1] = {name="Install Module", fct=function() end} end
--	if config.settings.update_remote then l[#l+1] = {name="Update", fct=function() game:registerDialog(require("mod.dialogs.UpdateAll").new()) end} end
	l[#l+1] = {name="Options", fct=function()
		local menu menu = require("engine.dialogs.GameMenu").new{
			"resume",
			"keybinds_all",
			"video",
			"sound",
		}
		game:registerDialog(menu)
	end}
	l[#l+1] = {name="Exit", fct=function() game:onQuit() end}
	if config.settings.cheat then l[#l+1] = {name="Reboot", fct=function() util.showMainMenu() end} end

	self.c_background = Button.new{text=game.stopped and "Enable background" or "Disable background", width=150, fct=function() self:switchBackground() end}
	self.c_version = Textzone.new{auto_width=true, auto_height=true, text=("#{bold}##B9E100#T-Engine4 version: %d.%d.%d"):format(engine.version[1], engine.version[2], engine.version[3])}

	if profile.auth then
		self.logged_url = "http://te4.org/users/"..profile.auth.page
		local str = "#FFFF00#Online Profile: "..profile.auth.name.."#{normal}#[#LIGHT_BLUE##{underline}#"..self.logged_url.."#LAST##{normal}#]"
		self.c_auth = Textzone.new{auto_width=true, auto_height=true, text=str}
	end

	self.c_list = List.new{width=self.iw, nb_items=#self.list, list=self.list, fct=function(item) end, font={"/data/font/VeraBd.ttf", 16}}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{left=0, bottom=0, absolute=true, ui=self.c_background},
		{right=0, top=0, absolute=true, ui=self.c_version},
		self.c_auth and {right=0, bottom=0, absolute=true, ui=self.c_auth} or nil,
	}
	self:setupUI(false, true)
	self.key:addBind("LUA_CONSOLE", function()
		if config.settings.cheat then
			game:registerDialog(require("engine.DebugConsole").new())
		end
	end)
	self.key:addBind("SCREENSHOT", function() game:saveScreenshot() end)

end

function _M:switchBackground()
	game.stopped = not game.stopped
	game:saveSettings("boot_menu_background", ("boot_menu_background = %s\n"):format(tostring(game.stopped)))
	self.c_background.text = game.stopped and "Enable background" or "Disable background"
	self.c_background:generate()

	if game.stopped then
		core.game.setRealtime(0)
	else
		core.game.setRealtime(8)
	end
end

function _M:on_recover_focus()
	game:unregisterDialog(self)
	local d = new()
	game:registerDialog(d)
end
