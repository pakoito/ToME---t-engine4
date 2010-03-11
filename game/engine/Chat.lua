require "engine.class"
require "engine.dialogs.Chat"

--- Handle chats between the player and NPCs
module(..., package.seeall, class.make)

function _M:init(name, npc, player)
	self.chats = {}
	self.npc = npc
	self.player = player

	local f = loadfile("/data/chats/"..name..".lua")
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
	return text:gsub("@playername@", self.player.name):gsub("@npcname@", self.npc.name)
end
