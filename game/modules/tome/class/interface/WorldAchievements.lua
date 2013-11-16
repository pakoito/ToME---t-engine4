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
local WA = require "engine.interface.WorldAchievements"

--- Handles achievements in a world
module(..., package.seeall, class.inherit(class.make{}, WA))

-- Duplicate from Game.lua because Game.lua is not loaded yet
local DIFFICULTY_EASY = 1
local DIFFICULTY_NORMAL = 2
local DIFFICULTY_NIGHTMARE = 3
local DIFFICULTY_INSANE = 4
local DIFFICULTY_MADNESS = 5
local PERMADEATH_INFINITE = 1
local PERMADEATH_MANY = 2
local PERMADEATH_ONE = 3


--- Make a new achievement with a name and desc
function _M:newAchievement(t)
	t.id = t.id or t.name
	t.id = t.id:upper():gsub("[ ]", "_")

	WA.newAchievement(self, t)

	if not t.no_difficulty_duplicate then
		-- Normal
		local t2 = table.clone(t)
		t2.id = "NORMAL_ROGUELIKE_"..t2.id
		t2.name = t2.name.." (Roguelike)"
		t2.difficulty = DIFFICULTY_NORMAL
		t2.permadeath = PERMADEATH_ONE
		WA.newAchievement(self, t2)
		
		-- Exploration
		local t2 = table.clone(t)
		t2.id = "EXPLORATION_"..t2.id
		t2.name = t2.name.." (Exploration mode)"
		t2.permadeath = PERMADEATH_INFINITE
		WA.newAchievement(self, t2)

		-- Nightmare
		local t2 = table.clone(t)
		t2.id = "NIGHTMARE_ADVENTURE_"..t2.id
		t2.name = t2.name.." (Nightmare (Adventure) difficulty)"
		t2.difficulty = DIFFICULTY_NIGHTMARE
		t2.permadeath = PERMADEATH_MANY
		WA.newAchievement(self, t2)

		local t2 = table.clone(t)
		t2.id = "NIGHTMARE_"..t2.id
		t2.name = t2.name.." (Nightmare (Roguelike) difficulty)"
		t2.difficulty = DIFFICULTY_NIGHTMARE
		t2.permadeath = PERMADEATH_ONE
		WA.newAchievement(self, t2)

		-- Insane
		local t2 = table.clone(t)
		t2.id = "INSANE_ADVENTURE_"..t2.id
		t2.name = t2.name.." (Insane (Adventure) difficulty)"
		t2.difficulty = DIFFICULTY_INSANE
		t2.permadeath = PERMADEATH_MANY
		WA.newAchievement(self, t2)

		local t2 = table.clone(t)
		t2.id = "INSANE_"..t2.id
		t2.name = t2.name.." (Insane (Roguelike) difficulty)"
		t2.difficulty = DIFFICULTY_INSANE
		t2.permadeath = PERMADEATH_ONE
		WA.newAchievement(self, t2)
		
		-- Madness
		local t2 = table.clone(t)
		t2.id = "MADNESS_ADVENTURE_"..t2.id
		t2.name = t2.name.." (Madness (Adventure) difficulty)"
		t2.difficulty = DIFFICULTY_MADNESS
		t2.permadeath = PERMADEATH_MANY
		WA.newAchievement(self, t2)

		local t2 = table.clone(t)
		t2.id = "MADNESS_"..t2.id
		t2.name = t2.name.." (Madness (Roguelike) difficulty)"
		t2.difficulty = DIFFICULTY_MADNESS
		t2.permadeath = PERMADEATH_ONE
		WA.newAchievement(self, t2)
	end
end

function _M:gainAchievement(id, src, ...)
	-- Redirect achievements to the main player, always
	src = game.party:findMember{main=true}
	local ret = WA.gainAchievement(self, id, src, ...)

	if ret then
		game:onTickEnd(function() game:playSound("actions/achievement") end, "achievementsound")
		game.state:checkDonation(true) -- They gained someting nice, they could be more receptive

		if core.steam and not config.settings.cheat then core.steam.forwardAchievement("TOME_"..id) end
	end
	return ret
end
