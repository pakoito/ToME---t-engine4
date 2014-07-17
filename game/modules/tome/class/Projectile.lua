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

require "engine.class"
require "engine.Projectile"
local Combat = require "mod.class.interface.Combat"

module(..., package.seeall, class.inherit(engine.Projectile))

_M.logCombat = Combat.logCombat

function _M:init(t, no_default)
	engine.Projectile.init(self, t, no_default)
end

--- Moves a projectile on the map
-- We override it to allow for movement animations
function _M:move(x, y, force)
	local ox, oy = self.x, self.y

	local moved = engine.Projectile.move(self, x, y, force)
	if moved and not force and ox and oy and (ox ~= self.x or oy ~= self.y) and config.settings.tome.smooth_move > 0 then
		self:setMoveAnim(ox, oy, config.settings.tome.smooth_move, nil)
	end

	return moved
end
function _M:tooltip(x, y)
	local tstr = tstring{"Projectile: ", self.name}

	if self.src and self.src.name then 
		local hostile = self.src.faction and game.player:reactionToward(self.src) or 0
		local color = {"color", "LIGHT_GREEN"}
		if hostile < 0 then color = {"color", "LIGHT_RED"}
		elseif hostile == 0 then color = {"color", "LIGHT_BLUE"}
		end
		tstr:add(true, "Origin: ", color, self.src.name, {"color", "LAST"})
	end

	if self.project and self.project.def and self.project.def.typ then
		if self.project.def.typ.selffire then
			local x = self.project.def.typ.selffire
			if x == true then x = 100 end
			tstr:add(true, "Affect origin chance: ", tostring(x), "%")
		end
		if self.project.def.typ.friendlyfire then
			local x = self.project.def.typ.friendlyfire
			if x == true then x = 100 end
			tstr:add(true, "Affect origin's friends chance: ", tostring(x), "%")
		end
	end

	if config.settings.cheat then
		tstr:add(true, "UID: ", tostring(self.uid), true, "Coords: ", tostring(x), "x", tostring(y))
	end
	return tstr
end

function _M:resolveSource()
	if self.src then
		return self.src:resolveSource()
	else
		return self
	end
end

--gets the full name of the projectile
function _M:getName()
	local name = self.name or "projectile"
	if self.src and self.src.name then
		return self.src.name:capitalize().."'s "..name
	else
		return name
	end
end
