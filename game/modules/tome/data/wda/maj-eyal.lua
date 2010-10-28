-- ToME - Tales of Maj'Eyal
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

-- Maj'Eyal worldmap directory AI

wda.cur_patrols = wda.cur_patrols or 0
wda.cur_hostiles = wda.cur_hostiles or 0

-- Spawn some patrols
if wda.cur_patrols < 3 then
	local e = game.zone:makeEntity(game.level, "encounters_npcs", {type="patrol"}, nil, true)
	if e then
		local spot = game.level:pickSpot{type="patrol", "allied-kingdoms"}
		if spot and not game.level.map(spot.x, spot.y, engine.Map.ACTOR) and not game.level.map.seens(spot.x, spot.y) then
			print("Spawned allied kingdom patrol", spot.x, spot.y, e.name)
			game.zone:addEntity(game.level, e, "actor", spot.x, spot.y)
			wda.cur_patrols = wda.cur_patrols + 1
			e.on_die = function() game.level.data.wda.cur_patrols = game.level.data.wda.cur_patrols - 1 end
		end
	end
end

-- Spawn some hostiles
if wda.cur_hostiles < 4 and rng.percent(5) then
	local e = game.zone:makeEntity(game.level, "encounters_npcs", {type="hostile"}, nil, true)
	if e then
		local spot = game.level:pickSpot{type="hostile", "random"}
		if spot and not game.level.map(spot.x, spot.y, engine.Map.ACTOR) and not game.level.map.seens(spot.x, spot.y) then
			print("Spawned hostile", spot.x, spot.y, e.name)
			game.zone:addEntity(game.level, e, "actor", spot.x, spot.y)
			wda.cur_hostiles = wda.cur_hostiles + 1
			e.on_die = function() game.level.data.wda.cur_hostiles = game.level.data.wda.cur_hostiles - 1 end
		end
	end
end
