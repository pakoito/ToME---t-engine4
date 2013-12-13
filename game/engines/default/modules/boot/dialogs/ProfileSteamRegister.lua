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
local Dialog = require "engine.ui.Dialog"
local Button = require "engine.ui.Button"
local Textbox = require "engine.ui.Textbox"
local Textzone = require "engine.ui.Textzone"

module(..., package.seeall, class.inherit(Dialog))

function _M:init()
	Dialog.init(self, "Steam User Account", 500, 400)
	self.alpha = 230

	self.c_desc = Textzone.new{width=math.floor(self.iw - 10), auto_height=true, text=[[Welcome to #GOLD#Tales of Maj'Eyal#LAST#.
To enjoy all the features the game has to offer it is #{bold}#highly#{normal}# recommended that you register your steam account.
Luckily this is very easy to do: you only require a profile name and optionally an email (we send very few email, maybe two a year at most).
]]}

	local login_filter = function(c)
		if c:find("^[a-z0-9]$") then return c end
		if c:find("^[A-Z]$") then return c:lower() end
		return nil
	end

	self.c_login = Textbox.new{title="Username: ", text="", chars=30, max_len=20, fct=function(text) self:okclick() end}
	self.c_email = Textbox.new{title="Email: ", size_title=self.c_login.title, text="", chars=30, max_len=60, fct=function(text) self:okclick() end}
	local ok = require("engine.ui.Button").new{text="Register", fct=function() self:okclick() end}
	local cancel = require("engine.ui.Button").new{text="Cancel", fct=function() self:cancelclick() end}
	self:loadUI{
		{left=0, top=0, ui=self.c_desc},
		{left=0, top=self.c_desc.h, ui=self.c_login},
		{left=0, top=self.c_desc.h+self.c_login.h+5, ui=self.c_email},
		{left=0, bottom=0, ui=ok},
		{right=0, bottom=0, ui=cancel},
	}
	self:setFocus(self.c_login)
	self:setupUI(true, true)

	self.key:addBinds{
		EXIT = function() game:unregisterDialog(self) end,
	}
end


function _M:okclick()
	if self.c_login.text:len() < 2 then
		self:simplePopup("Username", "Your username is too short")
		return
	end
	if self.c_email.text:len() > 0 and not self.c_email.text:find("..@..") then
		self:simplePopup("Email", "Your email does not look right.")
		return
	end

	local d = self:simpleWaiter("Registering...", "Registering on http://te4.org/, please wait...") core.display.forceRedraw()
	d:timeout(30, function() Dialog:simplePopup("Steam", "Steam client not found.")	end)
	core.steam.sessionTicket(function(ticket)
		if not ticket then
			Dialog:simplePopup("Steam", "Steam client not found.")
			return
		end

		profile:performloginSteam(ticket:toHex(), self.c_login.text, self.c_email.text ~= "" and self.c_email.text)
		profile:waitFirstAuth()
		d:done()
		if not profile.auth and profile.auth_last_error then
			if profile.auth_last_error == "already exists" then
				self:simplePopup("Error", "Username or Email already taken, please select an other one.")
			end
		elseif profile.auth then
			game:unregisterDialog(self)
		end
	end)
end

function _M:cancelclick()
	self.key:triggerVirtual("EXIT")
end
