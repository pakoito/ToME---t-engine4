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
local Textbox = require "engine.ui.Textbox"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init(dialogdef, profile_help_text)
	Dialog.init(self, "Online profile "..dialogdef.name, 500, 400)
	self.profile_help_text = profile_help_text
	self.dialogdef = dialogdef
	self.alpha = 230
	self.justlogin = dialogdef.justlogin

	self.c_desc = Textzone.new{width=math.floor(self.iw - 10), auto_height=true, text=self.profile_help_text}

	local login_filter = function(c)
		if c:find("^[a-z0-9]$") then return c end
		if c:find("^[A-Z]$") then return c:lower() end
		return nil
	end
	local pass_filter = function(c)
		if c == '\t' then return nil end
		return c
	end

	if self.justlogin then
		self.c_login = Textbox.new{title="Username: ", text="", chars=30, max_len=20, fct=function(text) self:okclick() end}
		self.c_pass = Textbox.new{title="Password: ", text="", chars=30, max_len=20, hide=true, fct=function(text) self:okclick() end}
		local ok = require("engine.ui.Button").new{text="Login", fct=function() self:okclick() end}
		local cancel = require("engine.ui.Button").new{text="Cancel", fct=function() self:cancelclick() end}

		self:loadUI{
			{left=0, top=0, ui=self.c_desc},
			{left=0, top=self.c_desc.h, ui=self.c_login},
			{left=0, top=self.c_desc.h+self.c_login.h+5, ui=self.c_pass},
			{left=0, bottom=0, ui=ok},
			{right=0, bottom=0, ui=cancel},
		}
		self:setFocus(self.c_login)
	else
		local pwa = "Password again: "
		self.c_login = Textbox.new{title="Username: ", size_title=pwa, text="", chars=30, max_len=20, filter=login_filter, fct=function(text) self:okclick() end}
		self.c_pass = Textbox.new{title="Password: ", size_title=pwa, text="", chars=30, max_len=20, hide=true, filter=pass_filter, fct=function(text) self:okclick() end}
		self.c_pass2 = Textbox.new{title=pwa, text="", size_title=pwa, chars=30, max_len=20, hide=true, filter=pass_filter, fct=function(text) self:okclick() end}
		self.c_email = Textbox.new{title="Email: ", size_title=pwa, text="", chars=30, max_len=60, filter=pass_filter, fct=function(text) self:okclick() end}
		local ok = require("engine.ui.Button").new{text="Create", fct=function() self:okclick() end}
		local cancel = require("engine.ui.Button").new{text="Cancel", fct=function() self:cancelclick() end}

		self:loadUI{
			{left=0, top=0, ui=self.c_desc},
			{left=0, top=self.c_desc.h, ui=self.c_login},
			{left=0, top=self.c_desc.h+self.c_login.h+5, ui=self.c_pass},
			{left=0, top=self.c_desc.h+self.c_login.h+self.c_pass.h+5, ui=self.c_pass2},
			{left=0, top=self.c_desc.h+self.c_login.h+self.c_pass.h+self.c_pass2.h+10, ui=self.c_email},
			{left=0, bottom=0, ui=ok},
			{right=0, bottom=0, ui=cancel},
		}
		self:setFocus(self.c_login)
	end
	self:setupUI(true, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end


function _M:okclick()
	if self.c_pass2 and self.c_pass.text ~= self.c_pass2.text then
		self:simplePopup("Password", "Password mismatch!")
		return
	end
	if self.c_login.text:len() < 2 then
		self:simplePopup("Username", "Your username is too short")
		return
	end
	if self.c_pass.text:len() < 4 then
		self:simplePopup("Password", "Your password is too short")
		return
	end
	if self.c_email and (self.c_email.text:len() < 6 or not self.c_email.text:find("@")) then
		self:simplePopup("Email", "Your email seems invalid")
		return
	end

	game:unregisterDialog(self)
	game:createProfile({create=self.c_email and true or false, login=self.c_login.text, pass=self.c_pass.text, email=self.c_email and self.c_email.text})
end

function _M:cancelclick()
	self.key:triggerVirtual("EXIT")
end
