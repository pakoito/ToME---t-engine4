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

local function get_coords()
	local function check(x, y)
		local level = game.level
		local function canEventGrid(level,x,y) return not level.map.attrs(x, y, "no_teleport") and not level.map:checkAllEntities(x, y, "change_level") end

		local list = {}
		for i = -2, 2 do for j = -2, 2 do
			if not canEventGrid(level, x+i, y+j) then return false end
			list[#list+1] = {x=x+i, y=y+j}
		end end
		if not game.state:canEventGrid(level, x, y) then return false end -- Check the center is also accessible

		if #list < 5 then return false
		else return list end
	end

	local x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
	local tries = 0
	while not check(x, y) and tries < 100 do
		x, y = rng.range(3, level.map.w - 4), rng.range(3, level.map.h - 4)
		tries = tries + 1
	end
	if tries >= 100 then return nil end
	return x, y
end

local list = {}
for i = 1, math.floor(7 * (1 + level.level / 2)) do
	local x, y = get_coords()
	if x then list[#list+1] = {x=x,y=y} end
end

game.zone.pyroclast_event_levels = game.zone.pyroclast_event_levels or {}
game.zone.pyroclast_event_levels[level.level] = list
print("Pyroclast crash sites")
table.print(list)

if not game.zone.pyroclast_event_on_turn then game.zone.pyroclast_event_on_turn = game.zone.on_turn or function() end end
game.zone.on_turn = function()
	if game.zone.pyroclast_event_on_turn then game.zone.pyroclast_event_on_turn() end

	if game.turn % 10 ~= 0 or not game.zone.pyroclast_event_levels[game.level.level] then return end

	local p = game:getPlayer(true)
	local x, y, si = nil, nil, nil
	for i = 1, #game.zone.pyroclast_event_levels[game.level.level] do
		local fx, fy = game.zone.pyroclast_event_levels[game.level.level][i].x, game.zone.pyroclast_event_levels[game.level.level][i].y
		if core.fov.distance(p.x, p.y, fx, fy) < 6 then x, y, si = fx, fy, i break end
	end

	if not x then return end
	print("Crashing at ",x,y, si)
	table.remove(game.zone.pyroclast_event_levels[game.level.level], si)

	game.level.data.meteor_x, game.level.data.meteor_y = x, y
	game.level.map:particleEmitter(game.level.data.meteor_x, game.level.data.meteor_y, 10, "meteor").on_remove = function()
		local x, y = game.level.data.meteor_x, game.level.data.meteor_y
		game.level.map:particleEmitter(x, y, 5, "fireflash", {radius=5})
		game:playSoundNear(game.player, "talents/fireflash")

		for i = x-2, x+2 do for j = y-2, y+2 do
			local og = game.level.map(i, j, engine.Map.TERRAIN)
			if (core.fov.distance(x, y, i, j) <= 1 or rng.percent(40)) and og and not og.escort_portal and not og.change_level then
				local g = game.zone.grid_list.LAVA_FLOOR:clone()
				g:resolve() g:resolve(nil, true)
				game.zone:addEntity(game.level, g, "terrain", i, j)
			end
		end end
		for i = x-2, x+2 do for j = y-2, y+2 do
			game.nicer_tiles:updateAround(game.level, i, j)
		end end
	end
end

return true
