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

-- Darken
game.level.map:setShown(0.3, 0.3, 0.3, 1)
game.level.map:setObscure(0.3*0.6, 0.3*0.6, 0.3*0.6, 0.6)
game.level.map:liteAll(0, 0, game.level.map.w, game.level.map.h, false)

-- Add random lightning firing off
game.level.data.thunderstorm_event_background = game.level.data.background
game.level.data.background = function(level)
	local Map = require "engine.Map"
	if rng.chance(30) then
		local x1, y1 = rng.range(10, level.map.w - 11), rng.range(10, level.map.h - 11)
		local x2, y2 = x1 + rng.range(-4, 4), y1 + rng.range(5, 10)
		level.map:particleEmitter(x1, y1, math.max(math.abs(x2-x1), math.abs(y2-y1)), "lightning", {tx=x2-x1, ty=y2-y1})
		game:playSoundNear({x=x1,y=y1}, "talents/thunderstorm")
	end

	if level.data.thunderstorm_event_background then level.data.thunderstorm_event_background(level) end
end

game.zone.thunderstorm_event_levels = game.zone.thunderstorm_event_levels or {}
game.zone.thunderstorm_event_levels[level.level] = true

if not game.zone.thunderstorm_event_on_turn then game.zone.thunderstorm_event_on_turn = game.zone.on_turn or function() end end
game.zone.on_turn = function()
	if game.zone.thunderstorm_event_on_turn then game.zone.thunderstorm_event_on_turn() end

	if game.turn % 10 ~= 0 or not game.zone.thunderstorm_event_levels[game.level.level] then return end

	if not rng.percent(2) then return end

	local i, j = util.findFreeGrid(game.player.x + rng.range(-5, 5), game.player.y + rng.range(-5, 5), 10, true, {[engine.Map.ACTOR]=true})
	if not i then return end

	local npcs = mod.class.NPC:loadList{"/data/general/npcs/gwelgoroth.lua"}
	local m = game.zone:makeEntity(game.level, "actor", {base_list=npcs}, nil, true)
	if m then
		m.exp_worth = 0
		game.zone:addEntity(game.level, m, "actor", i, j)
		local x1, y1 = i + rng.range(-4, 4), j + rng.range(-4, 4)
		game.level.map:particleEmitter(x1, y1, math.max(math.abs(i-x1), math.abs(j-y1)), "lightning", {tx=i-x1, ty=j-y1})
		game:playSoundNear({x=i,y=j}, "talents/thunderstorm")
	end

end

require("engine.ui.Dialog"):simplePopup("Thunderstorm", "As you walk into the area you notice a huge thunderstorm over your head, beware.")

return true
