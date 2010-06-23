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
require "engine.dialogs.Chat"

--- Handle chats between the player and NPCs
module(..., package.seeall, class.make)

function _M:init(name, npc, player)
	self.chats = {}
	self.npc = npc
	self.player = player

	local f, err = loadfile("/data/chats/"..name..".lua")
	if not f and err then error(err) end
	setfenv(f, setmetatable({
		newChat = function(c) self:addChat(c) end,
	}, {__index=_G}))
	self.default_id = f()
end

--- Adds a chat to the list of possible chats
function _M:addChat(c)
	assert(c.id, "no chat id")
	assert(c.text, "no chat text")
	assert(c.answers, "no chat answers")
	self.chats[c.id] = c
	print("[CHAT] loaded", c.id, c)
end

--- Invokes a chat
-- @param id the id of the first chat to run, if nil it will use the default one
function _M:invoke(id)
	local d = engine.dialogs.Chat.new(self, id or self.default_id)
	game:registerDialog(d)
end

--- Gets the chat with the given id
function _M:get(id)
	print("[CHAT] get", id)
	return self.chats[id]
end

--- Replace some keywords in the given text
function _M:replace(text)
	text = text:gsub("@playername@", self.player.name):gsub("@npcname@", self.npc.name)
	text = text:gsub("@playerdescriptor.(.-)@", function(what) return self.player.descriptor[what] end)
	return text
end
