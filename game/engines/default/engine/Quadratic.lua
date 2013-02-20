-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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

--- Handles a 3D "quadratic" object
-- It's mostly undeed, it simply allows quadratic to be serialized
module(..., package.seeall, class.make)

--- Make a particle emitter
function _M:init()
	self:loaded()
end

--- Serialization
function _M:save()
	return class.save(self, {
		q = true,
	})
end

function _M:cloned()
	self:loaded()
end

function _M:loaded()
	self.q = core.display.newQuadratic()
end
