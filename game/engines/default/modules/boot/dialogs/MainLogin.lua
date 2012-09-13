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
local SubDialog = require "engine.ui.SubDialog"
local List = require "engine.ui.List"
local Button = require "engine.ui.Button"
local Textzone = require "engine.ui.Textzone"
local Textbox = require "engine.ui.Textbox"

module(..., package.seeall, class.inherit(SubDialog))

function _M:init()
	SubDialog.init(self, "Player Account", 300, 100)
	self.__showup = false
--	self.absolute = true

	self:selectUI()

	self:generate()
end

function _M:selectUI()
	if profile.auth then
		self:uiStats()
	else
		self:uiLogin()
	end
end

function _M:uiLogin()
	local bt = Button.new{text="Login", width=50, fct=function() self:login() end}
	self.c_login = Textbox.new{title="Username: ", text="", chars=30, max_len=20, fct=function(text) self:login() end}
	self.c_pass = Textbox.new{title="Password: ", size_title=self.c_login.title, text="", chars=30, max_len=20, hide=true, fct=function(text) self:login() end}

	self:loadUI{
		{left=0, top=0, ui=self.c_login},
		{left=0, top=self.c_login.h, ui=self.c_pass},
		{hcenter=0, top=self.c_pass.h+self.c_login.h, ui=bt},
	}
	self:setupUI(false, true)
end

function _M:uiStats()
	local logoff = Textzone.new{text="#LIGHT_BLUE##{italic}#Logout", auto_height=true, width=50, fct=function() self:logout() end}

	self:loadUI{
		{right=0, top=0, ui=logoff},
	}
	self:setupUI(false, true)
end

function _M:login()
	if self.c_login.text:len() < 2 then
		Dialog:simplePopup("Username", "Your username is too short")
		return
	end
	if self.c_pass.text:len() < 4 then
		Dialog:simplePopup("Password", "Your password is too short")
		return
	end
	game:createProfile({create=false, login=self.c_login.text, pass=self.c_pass.text})
end

function _M:logout()
	profile:logOut()
end

--HUM !! finish
--oh and Jumper algo test
