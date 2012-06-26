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
local SubDialog = require "engine.ui.SubDialog"
local List = require "engine.ui.List"
local Button = require "engine.ui.Button"
local Textzone = require "engine.ui.Textzone"
local Textbox = require "engine.ui.Textbox"

module(..., package.seeall, class.inherit(SubDialog))

function _M:init()
	SubDialog.init(self, "Player Account", 100, 100)
	self.__showup = false
--	self.absolute = true

	local bt = Button.new{text="Login", width=50, fct=function() self:login() end}
	self.c_login = Textbox.new{title="Username: ", text="", chars=30, max_len=20, fct=function(text) self:login() end}
	self.c_pass = Textbox.new{title="Password: ", text="", chars=30, max_len=20, hide=true, fct=function(text) self:login() end}

	self:loadUI{
		{left=0, top=0, ui=self.c_login},
		{left=0, top=self.c_login.h, ui=self.c_pass},
		{left=0, top=self.c_pass.h+self.c_login.h, ui=bt},
	}
	self:setupUI(true, true)

	self:generate()
end
