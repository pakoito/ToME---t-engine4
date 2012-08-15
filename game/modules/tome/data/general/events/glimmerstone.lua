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
local x, y = game.state:findEventGrid(level)
if not x then return false end

local g = game.level.map(x, y, engine.Map.TERRAIN):cloneFull()
g = require("engine.Object").new(g)
g.name = "glimmerstone"
g.display='&' g.color_r=255 g.color_g=255 g.color_b=255 g.notice = true
g.add_displays = g.add_displays or {}
g.add_displays[#g.add_displays+1] = mod.class.Grid.new{image="terrain/moonstone_05.png", display_w=0.5, display_x=0.25, z=5}
g.nice_tiler = nil
g.act = function(self)
	local grids = core.fov.circle_grids(x, y, rng.range(1, 2), "block_move")
	for x, yy in pairs(grids) do for y, _ in pairs(yy) do
		if rng.chance(4) then
			if game.level.map.lites(x, y) then
				game.level.map.lites(x, y, false)
			else
				game.level.map.lites(x, y, true)
			end
			local target = game.level.map(x, y, engine.Map.ACTOR)
			if target then
				if target:canBe("stun") then
					target:setEffect(target.EFF_DAZED, 3, {})
					game.logSeen(target, "%s is affected by the glimmerstone!", target.name:capitalize())
				end
			end
		end
	end end

	self:useEnergy()
end
game.zone:addEntity(game.level, g, "terrain", x, y)
game.level:addEntity(g)

return true
