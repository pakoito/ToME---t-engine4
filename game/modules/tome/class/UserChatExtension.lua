-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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

--- Module that handles multiplayer chats extensions, automatically loaded by engine.UserChat if found
module(..., package.seeall, class.make)

function _M:init(chat)
	self.chat = chat
	chat:enableShadow(0.6)
end

function _M:sendObjectLink(o)
	local name = o:getName{do_color=true}:removeUIDCodes()
	local desc = tostring(o:getDesc(nil, nil, true)):removeUIDCodes()
	local ser = zlib.compress(table.serialize{kind="object-link", name=name, desc=desc})
	core.profile.pushOrder(string.format("o='ChatSerialData' channel=%q msg=%q", self.chat.cur_channel, ser))
end

function _M:sendActorLink(m)
	local name = m.name:removeUIDCodes()
	local desc = tostring(m:tooltip(m.x, m.y, game.player)):removeUIDCodes()
	if not desc then return end
	local ser = zlib.compress(table.serialize{kind="actor-link", name=name, desc=desc})
	core.profile.pushOrder(string.format("o='ChatSerialData' channel=%q msg=%q", self.chat.cur_channel, ser))
end

-- Receive a custom event
function _M:event(e)
	if e.se == "SerialData" then
		local data = zlib.decompress(e.msg)
		if not data then return end
		data = data:unserialize()
		if not data then return end
		if data.kind == "object-link" then
			self.chat:addMessage(e.channel, e.login, e.name, "#ANTIQUE_WHITE#has linked an item: #WHITE# "..data.name, {mode="tooltip", tooltip=data.desc})
			game.logChat("#LIGHT_BLUE#%s has linked an item <%s>", e.name, data.name)
		elseif data.kind == "actor-link" then
			self.chat:addMessage(e.channel, e.login, e.name, "#ANTIQUE_WHITE#has linked a creature: #WHITE# "..data.name, {mode="tooltip", tooltip=data.desc})
			game.logChat("#LIGHT_BLUE#%s has linked a creature <%s>", e.name, data.name)
		end
	end
end
