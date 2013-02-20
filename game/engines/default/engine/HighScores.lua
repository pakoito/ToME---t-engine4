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
local Map = require "engine.Map"

--- Define high score table support
---
--- This will eventually actually generate a GUI table and handle
--- filtering etc but for now it just generates a text string which
--- represents the list of high scores.

module(..., package.seeall, class.make)

--- to call these you need to have profile.mod pointing at the right module
--- that's normally automatic? But the code which runs from the 'boot'
--- module sets it up carefully

-- register a highscore against a campaign
function registerScore(world,details)
	details.type = "dead"

	profile:saveModuleProfile("scores", details)
end

-- scores of living players are stored against their name
function noteLivingScore(world,name,details)
	details.type = "alive"

	profile:saveModuleProfile("scores", details)
end

-- and should be removed when the char dies
function clearLivingScore(world,name)
	-- don't know how to write this
	-- don't know how to remove from the profile
end


function createHighScoreTable(world,formatters)
	local highscores = ""

	if not (profile.mod.scores and profile.mod.scores.sc and 
			profile.mod.scores.sc[world]) then
		print ("No scores yet!")
		return ""
	end

	print ("createHighScoreTable called with world : ",world)

	local defaultformatter = formatters.dead

	-- clone the scores and insert the alive ones in
	local scores = table.clone(profile.mod.scores.sc[world].dead or {})
	local alive = profile.mod.scores.sc[world].alive or {}
	for k,e in pairs(alive) do
		e.formatter = "alive"
		table.insert(scores,e)
	end

	table.sort(scores, function(a,b) return a.score and b.score and a.score > b.score end)
	for k = 1, #scores do
		local formatter = defaultformatter
		if scores[k].formatter then
			formatter = formatters[scores[k].formatter]
		end
		if formatter then
			highscores = highscores .. formatter:gsub(
				"{([a-z]+)}",
				function(field) 
					return scores[k][field] or "nil"
				end
			) .. "\n"
		end
	end

	return highscores
end
