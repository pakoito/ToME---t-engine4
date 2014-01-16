-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
	self.cjoined = {}
end

function _M:event(e)
	if e.e == "ChatTalk" then
		cprofile.pushEvent(string.format("e='Chat' se='Talk' channel=%q login=%q name=%q donator=%q status=%q msg=%q", e.channel, e.login, e.name, e.donator, e.status, e.msg))
		print("[USERCHAT] channel talk", e.login, e.channel, e.msg)
	elseif e.e == "ChatWhisper" then
		cprofile.pushEvent(string.format("e='Chat' se='Whisper' login=%q name=%q donator=%q status=%q msg=%q", e.login, e.name, e.donator, e.status, e.msg))
		print("[USERCHAT] whisper", e.login, e.msg)
	elseif e.e == "ChatAchievement" then
		cprofile.pushEvent(string.format("e='Chat' se='Achievement' channel=%q login=%q name=%q donator=%q status=%q msg=%q huge=%s first=%s", e.channel, e.login, e.name, e.donator, e.status, e.msg, tostring(e.huge), tostring(e.first)))
		print("[USERCHAT] channel achievement", e.login, e.channel, e.msg, e.huge, e.first)
	elseif e.e == "ChatSerialData" then
		local data = self.client.psock:receive(e.size)
		if data then
			e.msg = data
			cprofile.pushEvent(string.format("e='Chat' se='SerialData' channel=%q login=%q name=%q donator=%q status=%q msg=%q", e.channel, e.login, e.name, e.donator, e.status, e.msg))
			print("[USERCHAT] channel serial data", e.login, e.channel, e.size)
		end
	elseif e.e == "ChatJoin" then
		self.channels[e.channel] = self.channels[e.channel] or {}
		self.channels[e.channel][e.login] = true
		cprofile.pushEvent(string.format("e='Chat' se='Join' channel=%q login=%q name=%q donator=%q status=%q", e.channel, e.login, e.name, e.donator, e.status))
		print("[USERCHAT] channel join", e.login, e.channel)
	elseif e.e == "ChatPart" then
		self.channels[e.channel] = self.channels[e.channel] or {}
		self.channels[e.channel][e.login] = nil
		cprofile.pushEvent(string.format("e='Chat' se='Part' channel=%q login=%q name=%q donator=%q status=%q", e.channel, e.login, e.name, e.donator, e.status))
		print("[USERCHAT] channel part", e.login, e.channel)
	end
end

function _M:joined(channel)
	self.cjoined[channel] = true
	print("[ONLINE PROFILE] connected to channel", channel)
	cprofile.pushEvent(string.format("e='Chat' se='SelfJoin' channel=%q", channel))
end

function _M:parted(channel)
	self.cjoined[channel] = nil
	print("[ONLINE PROFILE] parted from channel", channel)
	cprofile.pushEvent(string.format("e='Chat' se='SelfPart' channel=%q", channel))
end

function _M:reconnect()
	if not self.client.sock then return end

	-- Rejoin every channels
	print("[ONLINE PROFILE] reconnecting to channels")
	for chan, _ in pairs(self.cjoined) do
		print("[ONLINE PROFILE] reconnecting to channel", chan)
		self.client:orderChatJoin{channel=chan}
	end
end
