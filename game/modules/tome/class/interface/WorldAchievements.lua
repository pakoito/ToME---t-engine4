-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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

local function findTile(t)
	if not fs.exists("/data/gfx/achievements/"..t.id:lower()..".png") then
		t.image = "trophy_gold.png"
		print("Achievement with default image not found", t.id, "/data/gfx/achievements/"..t.id:lower()..".png")
	else t.image = "achievements/"..t.id:lower()..".png"
	end
end

--- Make a new achievement with a name and desc
function _M:newAchievement(t)
	t.id = t.id or t.name
	t.id = t.id:upper():gsub("[ ]", "_")
	findTile(t)

	WA.newAchievement(self, t)

	if not t.no_difficulty_duplicate then
		-- Normal
		local t2 = table.clone(t)
		t2.id = "NORMAL_ROGUELIKE_"..t2.id
		t2.name = t2.name.." (Roguelike)"
		t2.difficulty = DIFFICULTY_NORMAL
		t2.permadeath = PERMADEATH_ONE
		findTile(t2)
		WA.newAchievement(self, t2)
		
		-- Exploration
		local t3 = table.clone(t)
		t3.id = "EXPLORATION_"..t3.id
		t3.name = t3.name.." (Exploration mode)"
		t3.permadeath = PERMADEATH_INFINITE
		findTile(t3)
		WA.newAchievement(self, t3)

		-- Add autogrant
		t.autogrant = {t3.id}
		t2.autogrant = {t.id, t3.id}

		-- Nightmare
		local t4 = table.clone(t)
		t4.id = "NIGHTMARE_ADVENTURE_"..t4.id
		t4.name = t4.name.." (Nightmare (Adventure) difficulty)"
		t4.difficulty = DIFFICULTY_NIGHTMARE
		t4.permadeath = PERMADEATH_MANY
		t4.autogrant = {t.id}
		findTile(t4)
		WA.newAchievement(self, t4)

		local t5 = table.clone(t)
		t5.id = "NIGHTMARE_"..t5.id
		t5.name = t5.name.." (Nightmare (Roguelike) difficulty)"
		t5.difficulty = DIFFICULTY_NIGHTMARE
		t5.permadeath = PERMADEATH_ONE
		t5.autogrant = {t4.id, t2.id}
		findTile(t5)
		WA.newAchievement(self, t5)

		-- Insane
		local t6 = table.clone(t)
		t6.id = "INSANE_ADVENTURE_"..t6.id
		t6.name = t6.name.." (Insane (Adventure) difficulty)"
		t6.difficulty = DIFFICULTY_INSANE
		t6.permadeath = PERMADEATH_MANY
		t6.autogrant = {t4.id}
		findTile(t6)
		WA.newAchievement(self, t6)

		local t7 = table.clone(t)
		t7.id = "INSANE_"..t7.id
		t7.name = t7.name.." (Insane (Roguelike) difficulty)"
		t7.difficulty = DIFFICULTY_INSANE
		t7.permadeath = PERMADEATH_ONE
		t7.autogrant = {t6.id, t5.id}
		findTile(t7)
		WA.newAchievement(self, t7)
		
		-- Madness
		local t8 = table.clone(t)
		t8.id = "MADNESS_ADVENTURE_"..t8.id
		t8.name = t8.name.." (Madness (Adventure) difficulty)"
		t8.difficulty = DIFFICULTY_MADNESS
		t8.permadeath = PERMADEATH_MANY
		t8.autogrant = {t6.id}
		findTile(t8)
		WA.newAchievement(self, t8)

		local t9 = table.clone(t)
		t9.id = "MADNESS_"..t9.id
		t9.name = t9.name.." (Madness (Roguelike) difficulty)"
		t9.difficulty = DIFFICULTY_MADNESS
		t9.permadeath = PERMADEATH_ONE
		t9.autogrant = {t8.id, t7.id}
		findTile(t9)
		WA.newAchievement(self, t9)
	end
end

function _M:gainAchievement(id, src, ...)
	local a = self.achiev_defs[id]

	-- Redirect achievements to the main player, always
	src = game.party:findMember{main=true}
	local ret = WA.gainAchievement(self, id, src, ...)

	if ret then
		game:onTickEnd(function() game:playSound("actions/achievement") end, "achievementsound")
		game.state:checkDonation(true) -- They gained someting nice, they could be more receptive

		local function subgrant(a)
			if a.autogrant then for _, sid in ipairs(a.autogrant) do
				local sa = self.achiev_defs[sid]
				if self:setAchievement(sid, src) then
					if core.steam and not config.settings.cheat then core.steam.forwardAchievement("TOME_"..sid) end
				end
				subgrant(sa)
			end end
		end
		subgrant(a)

		if core.steam and not config.settings.cheat then core.steam.forwardAchievement("TOME_"..id) end
	end
	return ret
end
