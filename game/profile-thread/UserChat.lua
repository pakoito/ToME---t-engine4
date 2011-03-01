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
local socket = require "socket"

module(..., package.seeall, class.make)

function _M:init(client)
	self.client = client
	self.channels = {}
end

function _M:event(e)
	if e.e == "ChatTalk" then
		cprofile.pushEvent(string.format("e='Chat' se='Talk' channel=%q login=%q name=%q msg=%q", e.channel, e.login, e.name, e.msg))
		print("[USERCHAT] channel talk", e.user, e.channel, e.msg)
	elseif e.e == "ChatJoin" then
		self.channels[e.channel] = self.channels[e.channel] or {}
		self.channels[e.channel][e.user] = true
		cprofile.pushEvent(string.format("e='Chat' se='Join' channel=%q login=%q name=%q ", e.channel, e.login, e.name))
		print("[USERCHAT] channel join", e.user, e.channel)
	elseif e.e == "ChatPart" then
		self.channels[e.channel] = self.channels[e.channel] or {}
		self.channels[e.channel][e.user] = nil
		cprofile.pushEvent(string.format("e='Chat' se='Part' channel=%q login=%q name=%q ", e.channel, e.login, e.name))
		print("[USERCHAT] channel part", e.user, e.channel)
	end
end
