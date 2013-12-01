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
local Achievement = require "engine.dialogs.Achievement"

--- Handles achievements in a world
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

--- Make a new achievement with a name and desc
function _M:newAchievement(t)
	assert(t.name, "no achievement name")
	assert(t.desc, "no achievement desc")

	t.mode = t.mode or "none"
	t.id = t.id or t.name
	t.id = t.id:upper():gsub("[ ]", "_")
	t.order = #self.achiev_defs+1

	self.achiev_defs[t.id] = t
	self.achiev_defs[#self.achiev_defs+1] = t
--	print("[ACHIEVEMENT] defined", t.order, t.id)
end

function _M:loadAchievements()
	self.achieved = {}
	self.playerachieved = {}

	if profile.mod.achievements then
		for id, e in pairs(profile.mod.achievements) do
			if self.achiev_defs[id] then
				self.achieved[id] = e
			end
		end
	end
end

--[[
function _M:achievementsDumpCSV()
	local f = fs.open("/achvs.csv", "w")
	f:write('"id","name","desc","earned","unearned"\n')
	for i, a in ipairs(self.achiev_defs) do
		f:write(('"%s","%s","%s","earned_%s.jpg","unearned_%s.jpg"\n'):
			format(
				"TOME_"..a.id,
				a.name:gsub('\\', '\\\\'):gsub('"', '\\"'),
				a.desc:gsub('\\', '\\\\'):gsub('"', '\\"'),
				a.id:lower(),
				a.id:lower()
			)
		)
	end
	f:close()
end
]]

function _M:getAchievementFromId(id)
	return self.achiev_defs[id]
end


--- Gain Personal achievement for player only
-- @param silent suppress the message to the player
-- @param id the achievement to gain
-- @param src who did it
function _M:gainPersonalAchievement(silent, id, src, ...)
	local a = self.achiev_defs[id]

	-- World achievements can not be gained multiple times
	if a.mode == "world" then return end

	if src.resolveSource then src = src:resolveSource() end

	src.achievements = src.achievements or {}
	if src.achievements[id] then return end

	src.achievements[id] = {turn=game.turn, who=self:achievementWho(src), when=os.date("%Y-%m-%d %H:%M:%S")}
	if not silent then
		local color = a.huge and "GOLD" or "LIGHT_GREEN"
		game.log("#"..color.."#Personal New Achievement: %s!", a.name)
		self:showAchievement("Personal New Achievement: #"..color.."#"..a.name, a)
		profile.chat:achievement(a.name, a.huge, false)
	end
	if a.on_gain then a:on_gain(src, true) end
	return true
end

--- Gain an achievement
-- @param id the achievement to gain
-- @param src who did it
-- @return true if an achievement was gained
function _M:gainAchievement(id, src, ...)
	local a = self.achiev_defs[id]
	if not a then error("Unknown achievement "..id) return end

	if self.achieved[id] and src.achievements and src.achievements[id] then return end

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

	if self.achieved[id] then return self:gainPersonalAchievement(false, id, src, ...) end
	self:gainPersonalAchievement(true, id, src, ...)

	self.achieved[id] = {turn=game.turn, who=self:achievementWho(src), when=os.date("%Y-%m-%d %H:%M:%S")}
	profile:saveModuleProfile("achievements", {id=id, turn=game.turn, who=self:achievementWho(src), gained_on=os.date("%Y-%m-%d %H:%M:%S")})
	local color = a.huge and "GOLD" or "LIGHT_GREEN"
	game.log("#"..color.."#New Achievement: %s!", a.name)
	self:showAchievement("New Achievement: #"..color.."#"..a.name, a)
	profile.chat:achievement(a.name, a.huge, true)

	if a.on_gain then a:on_gain(src) end
	return true
end

--- Show an achievement gain dialog
function _M:showAchievement(title, a)
	if not config.settings.cheat then
		game:registerDialog(Achievement.new("New Achievement", a))
	end
end

--- Format an achievement source
-- By default just uses the actor's name, you can overload it to do more
-- @param src the actor who did it
function _M:achievementWho(src)
	return src.name
end

--- Do we have this one ?
function _M:hasAchievement(id)
	return self.achieved[id] and true or false
end
