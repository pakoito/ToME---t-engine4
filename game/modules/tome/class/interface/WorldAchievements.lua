-- ToME - Tales of Maj'Eyal
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
local WA = require "engine.interface.WorldAchievements"

--- Handles achievements in a world
module(..., package.seeall, class.inherit(class.make{}, WA))

--- Make a new achievement with a name and desc
function _M:newAchievement(t)
	t.id = t.id or t.name
	t.id = t.id:upper():gsub("[ ]", "_")

	WA.newAchievement(self, t)

	if not t.no_difficulty_duplicate then
		local t2 = table.clone(t)
		t2.id = "EXPLORATION_"..t2.id
		t2.name = t2.name.." (Exploration mode)"
		WA.newAchievement(self, t2)

		local t2 = table.clone(t)
		t2.id = "INSANE_"..t2.id
		t2.name = t2.name.." (Insane difficulty)"
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
	end
	return ret
end
