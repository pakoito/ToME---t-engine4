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
local Module = require "engine.Module"
local Dialog = require "engine.ui.Dialog"
local List = require "engine.ui.List"
local Textzone = require "engine.ui.Textzone"
local Separator = require "engine.ui.Separator"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "Player Profile", 400, 200)

	self.c_desc = Textzone.new{width=300, height=self.ih, text=""}

	self.list = {}
	if profile.auth then
		self.list[#self.list+1] = {name="Logout", fct=function()
			Dialog:yesnoPopup("You are logged in", "Do you want to log out?", function(ret)
				if ret then
					profile:logOut()
				end
			end, "Log out", "Cancel")
		end}
	else
		self.list[#self.list+1] = {name="Login", fct=function()
			local dialogdef = {}
			dialogdef.fct = function(login) self:setPlayerLogin(login) end
			dialogdef.name = "login"
			dialogdef.justlogin = true
			game:registerDialog(require('mod.dialogs.ProfileLogin').new(dialogdef, game.profile_help_text))
		end}
		self.list[#self.list+1] = {name="Create Account", fct=function()
			local dialogdef = {}
			dialogdef.fct = function(login) self:setPlayerLogin(login) end
			dialogdef.name = "creation"
			dialogdef.justlogin = false
			game:registerDialog(require('mod.dialogs.ProfileLogin').new(dialogdef, game.profile_help_text))
		end}
	end

	self.c_list = List.new{width=150, nb_items=#self.list, list=self.list, fct=function(item) end}

	self:loadUI{
		{left=0, top=0, ui=self.c_list},
		{right=0, top=0, ui=self.c_desc},
		{left=self.c_list.w + 5, top=5, ui=Separator.new{dir="horizontal", size=self.ih - 10}},
	}
	self:setupUI(true, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end

function _M:select(item)
	if item and self.uis[2] then
--		self.uis[2].ui = item.zone
	end
end

function _M:on_recover_focus()
	game:unregisterDialog(self)
	local d = new()
	d.__showup = false
	game:registerDialog(d)
end
