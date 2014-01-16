-- ToME - Tales of Middle-Earth
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

-- The basic stuff used to damage a grid
setDefaultProjector(function(src, x, y, type, dam)
	local target = game.level.map(x, y, Map.ACTOR)
	if target then
		if src.player then dam = dam * 6 end
		local sx, sy = game.level.map:getTileToScreen(x, y)
		if target:takeHit(dam, src) then
			if src == game.player or target == game.player then
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -3, "Kill!", {255,0,255})
			end
		else
			if src == game.player then
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, -rng.float(2, 3), tostring(-math.ceil(dam)), {0,255,0})
			elseif target == game.player then
				game.flyers:add(sx, sy, 30, (rng.range(0,2)-1) * 0.5, rng.float(2, 3), tostring(-math.ceil(dam)), {255,0,0})
			end
		end
		return dam
	end
	return 0
end)

newDamageType{
	name = "physical", type = "PHYSICAL",
}
newDamageType{
	name = "acid", type = "ACID", text_color = "#GREEN#",
}
newDamageType{
	name = "arcane", type = "ARCANE", text_color = "#PURPLE#",
}
-- Light damage
newDamageType{
	name = "light", type = "LIGHT", text_color = "#YELLOW#",
}
-- The elemental damges
newDamageType{
	name = "fire", type = "FIRE", text_color = "#LIGHT_RED#",
}
newDamageType{
	name = "lightning", type = "LIGHTNING", text_color = "#ROYAL_BLUE#",
}
