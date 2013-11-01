-- ToME - Tales of Maj'Eyal
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
require "engine.World"
require "mod.class.interface.WorldAchievements"
local Savefile = require "engine.Savefile"

module(..., package.seeall, class.inherit(engine.World, mod.class.interface.WorldAchievements))

function _M:init()
	engine.World.init(self)
end

function _M:run()
	self:loadAchievements()
end

--- Requests the world to save
function _M:saveWorld(no_dialog)
	-- savefile_pipe is created as a global by the engine
	savefile_pipe:push("", "world", self)
end

--- Format an achievement source
-- @param src the actor who did it
function _M:achievementWho(src)
	local p = game.party:findMember{main=true}
	return p.name.." the "..p.descriptor.subrace.." "..p.descriptor.subclass.." level "..p.level
end

--- Gain an achievement
-- @param id the achievement to gain
-- @param src who did it
function _M:gainAchievement(id, src, ...)
	local a = self.achiev_defs[id]
	-- Do not unlock things in easy mode
	if not a then return end
	if game.difficulty == game.DIFFICULTY_EASY and not a.tutorial then return end

	if game.permadeath == game.PERMADEATH_INFINITE then id = "EXPLORATION_"..id end
	if game.difficulty == game.DIFFICULTY_NORMAL and game.permadeath == game.PERMADEATH_ONE then id = "NORMAL_ROGUELIKE_"..id end
	if game.difficulty == game.DIFFICULTY_NIGHTMARE and game.permadeath == game.PERMADEATH_MANY then id = "NIGHTMARE_ADVENTURE_".. id end
	if game.difficulty == game.DIFFICULTY_NIGHTMARE and game.permadeath == game.PERMADEATH_ONE then id = "NIGHTMARE_"..id end
	if game.difficulty == game.DIFFICULTY_INSANE and game.permadeath == game.PERMADEATH_MANY then id = "INSANE_ADVENTURE_"..id end
	if game.difficulty == game.DIFFICULTY_INSANE and game.permadeath == game.PERMADEATH_ONE then id = "INSANE_"..id end
	if game.difficulty == game.DIFFICULTY_MADNESS and game.permadeath == game.PERMADEATH_MANY then id = "MADNESS_ADVENTURE_"..id end
	if game.difficulty == game.DIFFICULTY_MADNESS and game.permadeath == game.PERMADEATH_ONE then id = "MADNESS_"..id end

	local knew = self.achieved[id]

	mod.class.interface.WorldAchievements.gainAchievement(self, id, src, ...)
	if not knew and self.achieved[id] then game.party.on_death_show_achieved[#game.party.on_death_show_achieved+1] = "Gained new achievement: "..a.name end
end

function _M:seenZone(short_name)
	self.seen_zones = self.seen_zones or {}
	self.seen_zones[short_name] = true
end

function _M:hasSeenZone(short_name)
	self.seen_zones = self.seen_zones or {}
	return self.seen_zones[short_name]
end
