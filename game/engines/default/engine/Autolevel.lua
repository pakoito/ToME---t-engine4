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

--- Handles autoleveling schemes
-- Probably used mainly for NPCS, although it could also be used for player allies
-- or players themselves for lazy players/modules
module(..., package.seeall, class.make)

_M.schemes = {}

function _M:registerScheme(t)
	assert(t.name, "no autolevel name")
	assert(t.levelup, "no autolevel levelup function")
	_M.schemes[t.name] = t
end

function _M:autoLevel(actor)
	if not actor.autolevel then return end
	assert(_M.schemes[actor.autolevel], "no autoleveling scheme "..actor.autolevel)

	_M.schemes[actor.autolevel].levelup(actor)
end
