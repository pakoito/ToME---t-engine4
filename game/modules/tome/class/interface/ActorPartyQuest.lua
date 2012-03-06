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

--- Handles actors quests
module(..., package.seeall, class.make)

_M.quest_class = "engine.Quest"

--- Grants a quest to an actor from the given quest definition
function _M:grantQuest(quest, args)
	-- Transfer the quest to the main player
	local mp = game.party:findMember{main=true}
	if mp ~= self then return mp:grantQuest(quest, args) end

	if type(quest) == "string" then
		local f, err = loadfile("/data/quests/"..quest..".lua")
		if not f and err then error(err) end
		local ret = args or {}
		setfenv(f, setmetatable(ret, {__index=_G}))
		f()
		ret.id = ret.id or quest
		quest = ret
	end
	if not quest.id then quest.id = quest.name end
	if self:hasQuest(quest.id) then return end

	assert(quest.name, "no quest name")
	assert(quest.desc, "no quest desc")

	local q = require(_M.quest_class).new(quest, self)
	if q.do_not_gain then return end

	self.quests = self.quests or {}
	self.quests[quest.id] = q
	self.quests[quest.id].gained_turn = game.turn
	print("[QUEST] given to", self, quest.id)
	self:check("on_quest_grant", quest)
end

--- Sets the status of a quest for an actor
-- If the actor does not have the quest, does nothing
function _M:setQuestStatus(quest, status, sub)
	-- Transfer the quest to the main player
	local mp = game.party:findMember{main=true}
	if mp ~= self then return mp:setQuestStatus(quest, status, sub) end

	print("[QUEST] try update status on", self.name, quest, status, sub)
	if not self.quests then return end
	if type(quest) == "table" then quest = quest.id end
	local q = self.quests[quest]
	if not q then return end
	if q:setStatus(status, sub, self) then
		self:check("on_quest_status", q, status, sub)
	end
end

--- Checks if the actor has this quest
function _M:hasQuest(id)
	-- Transfer the quest to the main player
	local mp = game.party:findMember{main=true}
	if mp ~= self then return mp:hasQuest(id) end

	if not self.quests then return false end
	return self.quests[id]
end

--- Checks the status of the given quest
-- If the actor does not have the quest, does nothing
function _M:isQuestStatus(quest, status, sub)
	-- Transfer the quest to the main player
	local mp = game.party:findMember{main=true}
	if mp ~= self then return mp:isQuestStatus(quest, status, sub) end

	if not self.quests then return end
	if type(quest) == "table" then quest = quest.id end
	local q = self.quests[quest]
	if not q then return end
	return q:isStatus(status, sub)
end

--- Removes the quest completely from the actor.
-- USE WITH CAUTION
function _M:removeQuest(id)
	-- Transfer the quest to the main player
	local mp = game.party:findMember{main=true}
	if mp ~= self then return mp:removeQuest(id) end

	if not self.quests then return false end
	self.quests[id] = nil
	return true
end
