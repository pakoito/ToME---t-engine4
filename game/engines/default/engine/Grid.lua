-- TE4 - T-Engine 4
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
local Entity = require "engine.Entity"

module(..., package.seeall, class.inherit(Entity))

-- When used on the map, do not draw alpha channel
_M._noalpha = true

_M.display_on_seen = true
_M.display_on_remember = true
_M.display_on_unknown = false

function _M:init(t, no_default)
	t = t or {}
	self.name = t.name
	Entity.init(self, t, no_default)
end

--- Setup minimap color for this entity
-- You may overload this method to customize your minimap
function _M:setupMinimapInfo(mo, map)
	if self:check("block_move") then mo:minimap(240, 240, 240)
	else mo:minimap(0, 0, 0)
	end
end


--- Return the kind of the entity
function _M:getEntityKind()
	return "grid"
end
