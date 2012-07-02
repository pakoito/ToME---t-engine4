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

local function canEventGrid(level,x,y) return not level.map.attrs(x, y, "no_teleport") and not level.map:checkAllEntities(x, y, "change_level") end

local function check(x, y)
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
if tries >= 100 then return false end

level.data.meteor_x = x
level.data.meteor_y = y

game.zone.meteor_event_levels = game.zone.meteor_event_levels or {}
game.zone.meteor_event_levels[level.level] = true

if not game.zone.meteor_event_on_turn then game.zone.meteor_event_on_turn = game.zone.on_turn or function() end end
game.zone.on_turn = function()
	if game.zone.meteor_event_on_turn then game.zone.meteor_event_on_turn() end

	if game.turn % 10 ~= 0 or not game.zone.meteor_event_levels[game.level.level] then return end

	local p = game:getPlayer(true)
	if core.fov.distance(p.x, p.y, game.level.data.meteor_x, game.level.data.meteor_y) > 3 then return end

	game.zone.meteor_event_levels[game.level.level] = nil

	game.level.map:particleEmitter(game.level.data.meteor_x, game.level.data.meteor_y, 10, "meteor").on_remove = function()
		local x, y = game.level.data.meteor_x, game.level.data.meteor_y
		game.level.map:particleEmitter(x, y, 10, "ball_fire", {radius=5})
		game:playSoundNear(game.player, "talents/fireflash")

		local terrains = mod.class.Grid:loadList("/data/general/grids/lava.lua")
		local npcs = mod.class.NPC:loadList("/data/general/npcs/losgoroth.lua")

		for i = x-2, x+2 do for j = y-2, y+2 do
			if core.fov.distance(x, y, i, j) <= 1 or rng.percent(40) then
				local g = terrains.LAVA_FLOOR:clone()
				g:resolve() g:resolve(nil, true)
				game.zone:addEntity(game.level, g, "terrain", i, j)

				if rng.percent(30) and not game.level.map(i, j, engine.Map.ACTOR) then
					local m = game.zone:makeEntity(game.level, "actor", {base_list=npcs}, nil, true)
					if m then
						m.resists = m.resists or {}
						m.resists[engine.DamageType.FIRE] = 100
						game.zone:addEntity(game.level, m, "actor", i, j)
					end
				end
			end
		end end
		for i = x-2, x+2 do for j = y-2, y+2 do
			game.nicer_tiles:updateAround(game.level, i, j)
		end end

		world:gainAchievement("EVENT_METEOR", game:getPlayer(true))
		require("engine.ui.Dialog"):simplePopup("Meteor!", "As you walk you notice a huge rock falling from the sky, it crashes right near you!")
	end
end

return true
