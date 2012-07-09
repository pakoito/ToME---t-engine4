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
game.level.map:setShown(0.6, 0.6, 0.6, 1)
game.level.map:setObscure(0.6*0.6, 0.6*0.6, 0.6*0.6, 0.6)
game.level.map:liteAll(0, 0, game.level.map.w, game.level.map.h, false)

-- Add snowing
local Map = require "engine.Map"
level.foreground_particle = require("engine.Particles").new("snowing", 1, {factor=10, width=Map.viewport.width, height=Map.viewport.height})

game.level.data.snowstorm_event_foreground = game.level.data.foreground
game.level.data.foreground = function(level, x, y, nb_keyframes)
	if level.data.snowstorm_event_foreground then level.data.snowstorm_event_foreground(level, x, y, nb_keyframes) end

	if not config.settings.tome.weather_effects or not level.foreground_particle then return end
	level.foreground_particle.ps:toScreen(x, y, true, 1)
end

game.zone.snowstorm_event_levels = game.zone.snowstorm_event_levels or {}
game.zone.snowstorm_event_levels[level.level] = true

if not game.zone.snowstorm_event_on_turn then game.zone.snowstorm_event_on_turn = game.zone.on_turn or function() end end
game.zone.on_turn = function()
	if game.zone.snowstorm_event_on_turn then game.zone.snowstorm_event_on_turn() end

	if game.turn % 10 ~= 0 or not game.zone.snowstorm_event_levels[game.level.level] then return end

end

require("engine.ui.Dialog"):simplePopup("Snowstorm", "As you walk into the area you notice a huge snowstorm over your head, beware.")

return true
