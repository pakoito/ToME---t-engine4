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
local Button = require "engine.ui.Button"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(data)
	Dialog.init(self, "User: "..data.name, 1,1)

	data.current_char = data.current_char or {}

	local str = tstring{{"color","GOLD"}, {"font","bold"}, data.name, {"color","LAST"}, {"font","normal"}, true, true}
	str:add({"color","ANTIQUE_WHITE"}, "Currently playing: ", {"color", "LAST"})
	if data.char_link then
		str:add({"font","italic"},{"color","LIGHT_BLUE"},data.current_char.title or "unknown",{"font","normal"},{"color","LAST"},true)
	else
		str:add(data.current_char.title or "unknown",true)
	end
	str:add({"color","ANTIQUE_WHITE"}, "Game: ", {"color", "LAST"}, data.current_char.module or "unknown", true)
	str:add({"color","ANTIQUE_WHITE"}, "Validation: ", {"color", "LAST"}, data.current_char.valid and "Game has been validated by the server" or "Game is not validated by the server", true)

	self.c_desc = Textzone.new{width=400, height=1, auto_height=true, text=str}
	local b_profile = require("engine.ui.Button").new{text="Go to online profile", fct=function() util.browserOpenUrl(data.profile) end}
	local b_char = require("engine.ui.Button").new{text="Go to online charsheet", fct=function() util.browserOpenUrl(data.char_link) end}

	local ui = {
		{left=0, top=0, ui=self.c_desc},
		{left=0, bottom=0, ui=b_profile},
	}
	if data.char_link then ui[#ui+1] = {right=0, bottom=0, ui=b_char} end
	self:loadUI(ui)
	self:setupUI(not rw, not rh)

	self.key:addBinds{
		ACCEPT = accept_key and "EXIT",
		EXIT = function()
			game:unregisterDialog(self)
			if on_exit then on_exit() end
		end,
	}
end
