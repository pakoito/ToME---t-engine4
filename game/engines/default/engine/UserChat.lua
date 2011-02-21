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
require "engine.ui.Base"
local KeyBind = require "engine.KeyBind"

--- Module that handles multiplayer chats
module(..., package.seeall, class.inherit(engine.ui.Base))

--- Creates the log zone
function _M:init()
	self.cur_channel = "global"
	self.channels = {}
end

--- Hook up in the current running game
function _M:setupOnGame()
	KeyBind:load("chat")
	_G.game.key:bindKeys() -- Make sure it updates

	_G.game.key:addBinds{
		USERCHAT_TALK = function()
			self:talkBox()
		end,
	}
end

function _M:event(e)
	-- Cancel if game is not fully loaded
	if type(game) ~= "table" then return end

	if e.se == "Talk" then
		e.msg = e.msg:removeColorCodes()

		self.channels[e.channel] = self.channels[e.channel] or {users={}, log={}}
		local log = self.channels[e.channel].log
		table.insert(log, 1, ("<%s> %s"):format(e.user, e.msg))
		while #log > 50 do table.remove(log) end
		game.log("#YELLOW#"..log[1])
	elseif e.se == "Join" then
		self.channels[e.channel] = self.channels[e.channel] or {users={}, log={}}
		self.channels[e.channel].users[e.user] = true
	elseif e.se == "Part" then
		self.channels[e.channel] = self.channels[e.channel] or {users={}, log={}}
		self.channels[e.channel].users[e.user] = nil
	end
end

function _M:talk(msg)
	if not profile.auth then return end
	if not msg then return end
	msg = msg:removeColorCodes()
	core.profile.pushOrder(string.format("o='ChatTalk' channel=%q msg=%q", self.cur_channel, msg))
end

--- Request a line to send
-- TODO: make it betetr than a simple dialog
function _M:talkBox()
	if not profile.auth then return end
	local d = require("engine.dialogs.GetText").new("Talk", self.cur_channel, 0, 250, function(text)
		self:talk(text)
	end)
	game:registerDialog(d)
end
