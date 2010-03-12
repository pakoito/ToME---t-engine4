require "engine.class"

--- Handles actors quests
module(..., package.seeall, class.make)

_M.quest_class = "engine.Quest"

--- Grants a quest to an actor from the given quest definition
function _M:grantQuest(quest)
	if type(quest) == "string" then
		local f = loadfile("/data/quests/"..quest..".lua")
		local ret = {}
		setfenv(f, setmetatable(ret, {__index=_G}))
		f()
		ret.id = ret.id or quest
		quest = ret
	end
	if not quest.id then quest.id = quest.name end
	if self:hasQuest(quest.id) then return end

	assert(quest.name, "no quest name")
	assert(quest.desc, "no quest desc")

	self.quests = self.quests or {}
	self.quests[quest.id] = require(_M.quest_class).new(quest, self)
	self.quests[quest.id].gained_turn = game.turn
	print("[QUEST] given to", self, quest.id)
	self:check("on_quest_grant", quest)
end

--- Sets the status of a quest for an actor
-- If the actor does not have the quest, does nothing
function _M:setQuestStatus(quest, status, sub)
	print("[QUEST] try update status on", self.name, quest, status, sub)
	if not self.quests then return end
	local q = self.quests[quest]
	if not q then return end
	if q:setStatus(status, sub, self) then
		self:check("on_quest_status", q, status, sub)
	end
end

--- Checks if the actor has this quest
function _M:hasQuest(id)
	if not self.quests then return false end
	return self.quests[id] and true or false
end

--- Checks the status of the given quest
-- If the actor does not have the quest, does nothing
function _M:isQuestStatus(quest, status, sub)
	if not self.quests then return end
	local q = self.quests[quest]
	if not q then return end
	return q:isStatus(status, sub)
end
