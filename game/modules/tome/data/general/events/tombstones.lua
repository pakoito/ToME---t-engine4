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

-- Find a random spot
local nb = rng.range(3, 5)
for i = 1, nb do

local x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
local tries = 0
while not game.state:canEventGrid(level, x, y) and tries < 100 do
	x, y = rng.range(1, level.map.w - 2), rng.range(1, level.map.h - 2)
	tries = tries + 1
end
if tries < 100 then
	local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
	g.name = "grave"
	g.display='&' g.color_r=255 g.color_g=255 g.color_b=255 g.notice = true
	g.add_displays = g.add_displays or {}
	g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/grave_unopened_0"..rng.range(1,3).."_64.png", display_y=-1, display_h=2}
	g.nice_tiler = nil
	g.block_move = function(self, x, y, who, act, couldpass)
		if not who or not who.player or not act then return false end
		who:runStop("grave")
		require("engine.ui.Dialog"):yesnoPopup("Grave", "Do you wish to disturb the grave?", function(ret) if ret then
			self.block_move = nil
			if rng.percent(20) then game.log("There is nothing there.") return end

			local m = game.zone:makeEntity(game.level, "actor", {properties={"undead"}, add_levels=10, random_boss={nb_classes=1, rank=3, ai = "tactical", loot_quantity = 0, no_loot_randart = true}}, nil, true)
			local x, y = util.findFreeGrid(who.x, who.y, 5, true, {[engine.Map.ACTOR]=true})
			if m and x and y then
				game.zone:addEntity(game.level, m, "actor", x, y)
				game.log("You were not the first here: the corpse was turned into an undead.")
			else
				game.log("There is nothing there.")
			end
		end end)
		return false
	end,
	game.zone:addEntity(game.level, g, "terrain", x, y)
end

end -- for

return true
