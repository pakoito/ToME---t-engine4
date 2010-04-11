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
local Dialog = require "engine.Dialog"

--- Handles archievements in a world
module(..., package.seeall, class.make)

_M.achiev_defs = {}

--- Loads achievements
function _M:loadDefinition(dir)
	for i, file in ipairs(fs.list(dir)) do
		if file:find("%.lua$") then
			local f, err = loadfile(dir.."/"..file)
			if not f and err then error(err) end
			setfenv(f, setmetatable({
				newAchievement = function(t) self:newAchievement(t) end,
			}, {__index=_G}))
			f()
		end
	end
end

--- Make a new achivement with a name and desc
function _M:newAchievement(t)
	assert(t.name, "no achivement name")
	assert(t.desc, "no achivement desc")

	t.mode = t.mode or "none"
	t.id = t.id or t.name
	t.id = t.id:upper():gsub("[ ]", "_")
	t.order = #self.achiev_defs+1

	self.achiev_defs[t.id] = t
	self.achiev_defs[#self.achiev_defs+1] = t
	print("[ACHIEVEMENT] defined", t.order, t.id)
end

function _M:init()
	self.achieved = {}
end

function _M:getAchievementFromId(id)
	return self.achiev_defs[id]
end

--- Gain an achievement
-- @param id the achivement to gain
-- @param src who did it
function _M:gainAchievement(id, src, ...)
	local a = self.achiev_defs[id]
	if not a then error("Unknown achievement "..id) return end
	if self.achieved[id] then return end

	if a.can_gain then
		local data = nil
		if a.mode == "world" then
			self.achievement_data = self.achievement_data or {}
			self.achievement_data[id] = self.achievement_data[id] or {}
			data = self.achievement_data[id]
		elseif a.mode == "game" then
			game.achievement_data = game.achievement_data or {}
			game.achievement_data[id] = game.achievement_data[id] or {}
			data = game.achievement_data[id]
		elseif a.mode == "player" then
			src.achievement_data = src.achievement_data or {}
			src.achievement_data[id] = src.achievement_data[id] or {}
			data = src.achievement_data[id]
		end
		if not a.can_gain(data, src, ...) then return end
	end

	self.achieved[id] = {turn=game.turn, who=self:achievementWho(src), when=os.date("%Y-%m-%d %H:%M:%S")}
	game.log("#LIGHT_GREEN#New Achievement: %s!", a.name)
	Dialog:simplePopup("New Achievement: #LIGHT_GREEN#"..a.name, a.desc)
end

--- Format an achievement source
-- By default just uses the actor's name, you can overload it to do more
-- @param src the actor who did it
function _M:achievementWho(src)
	return src.name
end
